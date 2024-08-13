// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {
    inEuint8,
    inEuint16,
    inEuint32,
    inEuint64,
    inEuint128,
    inEuint256,
    inEaddress,
    inEbool
} from '@fhenixprotocol/contracts/FHE.sol';

import { Test } from "forge-std/src/Test.sol";
import { MockFheOps } from "@fhenixprotocol/contracts/utils/debug/MockFheOps.sol";

contract FheEnabled is Test {
    function initializeFhe() public {
        MockFheOps fheos = new MockFheOps();
        bytes memory code = address(fheos).code;
        vm.etch(address(128), code);
    }

    function unseal(address, string memory value) public pure returns (uint256) {
        bytes memory bytesValue = bytes(value);
        require(bytesValue.length == 32, "Invalid input length");

        uint256 result;
        assembly {
            result := mload(add(bytesValue, 32))
        }

        return result;
    }

    function encrypt8(uint256 value) public pure returns (inEuint8 memory) {
        return inEuint8(uint256ToBytes(value), 0);
    }

    function encrypt16(uint256 value) public pure returns (inEuint16 memory) {
        return inEuint16(uint256ToBytes(value), 0);
    }

    function encrypt32(uint256 value) public pure returns (inEuint32 memory) {
        return inEuint32(uint256ToBytes(value), 0);
    }

    function encrypt64(uint256 value) public pure returns (inEuint64 memory) {
        return inEuint64(uint256ToBytes(value), 0);
    }

    function encrypt128(uint256 value) public pure returns (inEuint128 memory) {
        return inEuint128(uint256ToBytes(value), 0);
    }

    function encrypt256(uint256 value) public pure returns (inEuint256 memory) {
        return inEuint256(uint256ToBytes(value), 0);
    }

    function encryptAddress(uint256 value) public pure returns (inEaddress memory) {
        return inEaddress(uint256ToBytes(value), 0);
    }

    function encryptBool(uint256 value) public pure returns (inEbool memory) {
        return inEbool(uint256ToBytes(value), 0);
    }

    function uint256ToBytes(uint256 value) private pure returns (bytes memory) {
        bytes memory result = new bytes(32);

        assembly {
            mstore(add(result, 32), value)
        }

        return result;
    }

}
