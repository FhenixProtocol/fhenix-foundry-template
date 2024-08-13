// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { FHERC20 } from "@fhenixprotocol/contracts/experimental/token/FHERC20/FHERC20.sol";
import { inEuint128 } from "@fhenixprotocol/contracts/FHE.sol";
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";

error FHERC20NotAuthorized();

contract ExampleToken is FHERC20, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 public lol;

    constructor(string memory name, string memory symbol, uint256 initialBalance) FHERC20(name, symbol) {
        lol = initialBalance;
        // _mintEncrypted(msg.sender, encryptedBalance);
        _grantRole(MINTER_ROLE, msg.sender);
        _mint(msg.sender, initialBalance);
    }

    function mintEncrypted(address recipient, inEuint128 memory amount) public {
        if (hasRole(MINTER_ROLE, msg.sender)) {
            _mintEncrypted(recipient, amount);
        } else {
            revert FHERC20NotAuthorized();
        }
    }

    function mint(address _address, uint256 _amount) public {
        _mint(_address, _amount);
    }
}
