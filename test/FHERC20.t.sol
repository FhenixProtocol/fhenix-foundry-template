// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/src/Test.sol";

import { ExampleToken, FHERC20NotAuthorized } from "../src/FHERC20.sol";
import { FheEnabled } from "../util/FheHelper.sol";
import { Permission, PermissionHelper } from "../util/PermissionHelper.sol";

import { inEuint128, euint128 } from "@fhenixprotocol/contracts/FHE.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

/// @dev If this is your first time with Forge, read this tutorial in the Foundry Book:
/// https://book.getfoundry.sh/forge/writing-tests
contract TokenTest is Test, FheEnabled {
    ExampleToken internal token;
    PermissionHelper private permitHelper;

    address public owner;
    uint256 public ownerPrivateKey;

    uint256 private receiverPrivateKey;
    address private receiver;

    Permission private permission;
    Permission private permissionReceiver;

    /// @dev A function invoked before each test case is run.
    function setUp() public virtual {
        // Required to mock FHE operations - do not forget to call this function
        // *****************************************************
        initializeFhe();
        // *****************************************************

        receiverPrivateKey = 0xB0B;
        receiver = vm.addr(receiverPrivateKey);

        ownerPrivateKey = 0xA11CE;
        owner = vm.addr(ownerPrivateKey);

        vm.startPrank(owner);

        // Instantiate the contract-under-test.
        token = new ExampleToken("hello", "TST", 10_000_000);
        permitHelper = new PermissionHelper(address(token));

        permission = permitHelper.generatePermission(ownerPrivateKey);
        permissionReceiver = permitHelper.generatePermission(receiverPrivateKey);

        vm.stopPrank();
    }

    /// @dev Basic test for the balanceOf function of the plaintext ERC20.
    function testBalanceOf() external {
        assertEq(0, token.balanceOf(msg.sender));
        uint256 toMint = 1.0 * 10 ^ token.decimals();
        token.mint(msg.sender, toMint);
        assertEq(token.balanceOf(msg.sender), toMint);
    }

    // @dev Failing test for mintEncrypted function with unauthorized minter
    function testMintEncryptedNoPermissions() public {
        uint128 value = 50;
        inEuint128 memory inputValue = encrypt128(value);

        vm.expectRevert(FHERC20NotAuthorized.selector);
        token.mintEncrypted(owner, inputValue);
    }

    // @dev Test mintEncrypted function with authorized minter
    function testMintEncrypted() public {
        uint128 value = 50;
        inEuint128 memory encryptedValue = encrypt128(value);

        vm.prank(owner);
        token.mintEncrypted(owner, encryptedValue);

        string memory encryptedBalance = token.balanceOfEncrypted(owner, permission);
        uint256 balance = unseal(address(token), encryptedBalance);
        assertEq(balance, uint256(value));
    }

    // @dev Test transferEncrypted function - tests reading and writing encrypted balances and using permissions
    function testTransferEncrypted() public {
        uint128 value = 50;
        inEuint128 memory encryptedValue = encrypt128(value);

        vm.startBroadcast(owner);

        token.mintEncrypted(owner, encryptedValue);

        string memory encryptedBalance = token.balanceOfEncrypted(owner, permission);
        uint256 balance = unseal(address(token), encryptedBalance);
        assertEq(balance, uint256(value));

        uint128 transferValue = 10;

        inEuint128 memory encryptedTransferValue = encrypt128(transferValue);
        euint128 transferred = token.transferEncrypted(receiver, encryptedTransferValue);
        assertEq(transferred.decrypt(), transferValue);

        string memory encryptedBalanceAfterTransfer = token.balanceOfEncrypted(owner, permission);
        uint256 balanceAfterTransfer = unseal(address(token), encryptedBalanceAfterTransfer);
        assertEq(balanceAfterTransfer, uint256(value - transferValue));

        string memory encryptedBalanceReceiver = token.balanceOfEncrypted(receiver, permissionReceiver);
        uint256 balanceReceiver = unseal(address(token), encryptedBalanceReceiver);
        assertEq(balanceReceiver, uint256(transferValue));

        vm.stopBroadcast();
    }
}
