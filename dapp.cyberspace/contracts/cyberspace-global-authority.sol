pragma solidity ^0.8.0;

import {D} from "./infrastructure/ds.patricia-data.sol";
import {Network} from "./infrastructure/ds.network.sol";

contract CyberspaceGlobalAuthority {
    using Network for Network.Tree;
    Network.Tree networktree;

    constructor () public {
    }

    function insert(bytes memory key, bytes memory value) public {
        networktree.insert(key, value);
    }

    function get(bytes memory key) public view returns (bytes memory) {
        return networktree.get(key);
    }

    function safeGet(bytes memory key) public view returns (bytes memory) {
        return networktree.safeGet(key);
    }

    function doesInclude(bytes memory key) public view returns (bool) {
        return networktree.doesInclude(key);
    }

    function getValue(bytes32 hash) public view returns (bytes memory) {
        return networktree.values[hash];
    }

    function getRootHash() public view returns (bytes32) {
        return networktree.getRootHash();
    }

    function getNode(bytes32 hash) public view returns (uint, bytes32, bytes32, uint, bytes32, bytes32) {
        return networktree.getNode(hash);
    }

    function getRootEdge() public view returns (uint, bytes32, bytes32) {
        return networktree.getRootEdge();
    }

    function getProof(bytes memory key) public view returns (uint branchMask, bytes32[] memory _siblings) {
        return networktree.getProof(key);
    }

    function getNonInclusionProof(bytes memory key) public view returns (
        bytes32 leafLabel,
        bytes32 leafNode,
        uint branchMask,
        bytes32[] memory _siblings
    ) {
        return networktree.getNonInclusionProof(key);
    }

    function verifyProof(bytes32 rootHash, bytes memory key, bytes memory value, uint branchMask, bytes32[] memory siblings) public pure {
        networktree.verifyProof(rootHash, key, value, branchMask, siblings);
    }

    function verifyNonInclusionProof(bytes32 rootHash, bytes memory key, bytes32 leafLabel, bytes32 leafNode, uint branchMask, bytes32[] memory siblings) public pure {
        networktree.verifyNonInclusionProof(rootHash, key, leafLabel, leafNode, branchMask, siblings);
    }
}
