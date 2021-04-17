pragma solidity ^0.8.0;

import {D} from "./patricia-tree/ds.patricia-data.sol";
import {PatriciaTree} from "./patricia-tree/ds.patricia-tree.sol";

contract CyberspaceNetworkTree {
    using PatriciaTree for PatriciaTree.Tree;
    PatriciaTree.Tree network;

    constructor () public {
    }

    function insert(bytes memory key, bytes memory value) public {
        network.insert(key, value);
    }

    function get(bytes memory key) public view returns (bytes memory) {
        return network.get(key);
    }

    function safeGet(bytes memory key) public view returns (bytes memory) {
        return network.safeGet(key);
    }

    function doesInclude(bytes memory key) public view returns (bool) {
        return network.doesInclude(key);
    }

    function getValue(bytes32 hash) public view returns (bytes memory) {
        return network.values[hash];
    }

    function getRootHash() public view returns (bytes32) {
        return network.getRootHash();
    }

    function getNode(bytes32 hash) public view returns (uint, bytes32, bytes32, uint, bytes32, bytes32) {
        return network.getNode(hash);
    }

    function getRootEdge() public view returns (uint, bytes32, bytes32) {
        return network.getRootEdge();
    }

    function getProof(bytes memory key) public view returns (uint branchMask, bytes32[] memory _siblings) {
        return network.getProof(key);
    }

    function getNonInclusionProof(bytes memory key) public view returns (
        bytes32 leafLabel,
        bytes32 leafNode,
        uint branchMask,
        bytes32[] memory _siblings
    ) {
        return network.getNonInclusionProof(key);
    }

    function verifyProof(bytes32 rootHash, bytes memory key, bytes memory value, uint branchMask, bytes32[] memory siblings) public pure {
        PatriciaTree.verifyProof(rootHash, key, value, branchMask, siblings);
    }

    function verifyNonInclusionProof(bytes32 rootHash, bytes memory key, bytes32 leafLabel, bytes32 leafNode, uint branchMask, bytes32[] memory siblings) public pure {
        PatriciaTree.verifyNonInclusionProof(rootHash, key, leafLabel, leafNode, branchMask, siblings);
    }
}
