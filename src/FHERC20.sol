// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

// import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import { FHERC20 } from "@fhenixprotocol/contracts/experimental/token/FHERC20/FHERC20.sol";
import { FHE, euint128 } from "@fhenixprotocol/contracts/FHE.sol";
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";

contract ExampleToken is FHERC20, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 public lol;

    constructor(string memory name, string memory symbol, uint256 initialBalance) FHERC20(name, symbol) {
        lol = initialBalance;
        // _mintEncrypted(msg.sender, encryptedBalance);
        _grantRole(MINTER_ROLE, msg.sender);
        _mint(msg.sender, initialBalance);
    }

    // function mintEncrypted(address recipient, inEuint128 memory amount) public {
    //     if (hasRole(MINTER_ROLE, msg.sender)) {
    //         _mintEncrypted(recipient, amount);
    //     }
    // }

    function test(uint256 input) public returns (uint256 result) {
        euint128 encrypted = FHE.asEuint128(input) + FHE.asEuint128(input);
        return encrypted.decrypt();
    }

    function mint(address _address, uint256 _amount) public {
        _mint(_address, _amount);
    }
}
