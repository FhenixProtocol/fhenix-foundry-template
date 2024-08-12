// // SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { ExampleToken } from "../src/FHERC20.sol";

import { BaseScript } from "./Base.s.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract Deploy is BaseScript {
    function run() public broadcast returns (ExampleToken foo) {
        foo = new ExampleToken("test", "TST", 10_000);
    }
}
