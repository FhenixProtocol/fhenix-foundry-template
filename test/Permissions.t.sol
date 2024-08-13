// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

import { Permission, Permissioned } from "@fhenixprotocol/contracts/access/Permissioned.sol";

import { PermissionHelper } from "../util/PermissionHelper.sol";

contract PermissionedTest is Test {
    PermissionedTestContract private permissions;
    PermissionHelper private permitHelper;

    address private owner;
    uint256 private ownerPrivateKey;

    function setUp() public {
        permissions = new PermissionedTestContract();
        permitHelper = new PermissionHelper(address(permissions));
    }

    function test_OnlySender() external {
        // Generate permission
        ownerPrivateKey = 0xA11CE;
        owner = vm.addr(ownerPrivateKey);

        Permission memory permission = permitHelper.generatePermission(ownerPrivateKey);

        console2.log(owner);

        // Call function with permission
        uint256 result = permissions.someFunctionWithOnlySender(owner, permission);
        assertEq(result, 42);
    }
}

contract PermissionedTestContract is Permissioned {
    function someFunctionWithOnlySender(
        address owner,
        Permission memory permission
    )
        public
        view
        onlyPermitted(permission, owner)
        returns (uint256)
    {
        return 42;
    }
}
