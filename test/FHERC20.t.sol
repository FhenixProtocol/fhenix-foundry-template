// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

import { ExampleToken } from "../src/FHERC20.sol";
import { MockFheOps } from "../util/MockFheOps.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

/// @dev If this is your first time with Forge, read this tutorial in the Foundry Book:
/// https://book.getfoundry.sh/forge/writing-tests
contract FooTest is Test {
    ExampleToken internal foo;

    /// @dev A function invoked before each test case is run.
    function setUp() public virtual {
        MockFheOps fheos = new MockFheOps();
        bytes memory code = address(fheos).code;
        vm.etch(address(128), code);
        // Instantiate the contract-under-test.
        console2.log(msg.sender);
        foo = new ExampleToken("hello", "TST", 10_000_000);
    }

    /// @dev Basic test. Run it with `forge test -vvv` to see the console log.
    function test_Example() external {
        console2.log("Hello World");
        console2.log(msg.sender);
        assertEq(0, foo.balanceOf(msg.sender));

        uint256 toMint = 1.0 * 10 ^ foo.decimals();
        foo.mint(msg.sender, toMint);
        assertEq(foo.balanceOf(msg.sender), toMint);
    }

    function test_Test() external {
        uint256 input = 10;
        uint256 result = foo.test(input);
        assertEq(result, input * 2);
    }

    // /// @dev Fuzz test that provides random values for an unsigned integer, but which rejects zero as an input.
    // /// If you need more sophisticated input validation, you should use the `bound` utility instead.
    // /// See https://twitter.com/PaulRBerg/status/1622558791685242880
    // function testFuzz_Example(uint256 x) external view {
    //     vm.assume(x != 0); // or x = bound(x, 1, 100)
    //     assertEq(foo.id(x), x, "value mismatch");
    // }
}
