// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;
import { Test } from "forge-std/src/Test.sol";

import { Permission } from "@fhenixprotocol/contracts/access/Permissioned.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract PermissionHelper is Test {

    address _signer_contract;

    bytes32 _hashedName;
    bytes32 _hashedVersion;

    bytes32 private constant TYPE_HASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    constructor(address as_signer) {
        _signer_contract = as_signer;
        _hashedName = keccak256(bytes("Fhenix Permission"));
        _hashedVersion = keccak256(bytes("1.0"));
    }

    function _buildDomainSeparator() private view returns (bytes32) {
        return keccak256(abi.encode(TYPE_HASH, _hashedName, _hashedVersion, block.chainid, address(_signer_contract)));
    }

    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return MessageHashUtils.toTypedDataHash(_buildDomainSeparator(), structHash);
    }


    function generatePermission(uint256 signerPrivateKey) public view returns (Permission memory) {
        bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
            keccak256("Permissioned(bytes32 publicKey)"),
            bytes32(0)
        )));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPrivateKey, digest);
        bytes memory signature = bytes.concat(r, s, bytes1(v));

        return Permission(bytes32(0), signature);
    }
}