pragma solidity >=0.4.22 <0.9.0;

import {GraphLib, HitchensUnorderedKeySetLib} from "./lib/graph.sol";
import "./lib/graph.sol";
import "chainlink/contracts/ChainlinkClient.sol";
import "chainlink/contracts/vendor/Ownable.sol";
import {
    SafeMath as SafeMath_Chainlink
} from "chainlink/v0.5/contracts/vendor/SafeMath.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

// enum StatePolicyType { PendingReview, Healthy, UnHealthy, Modified,
//                 PendingInspection, Inspected, CommisionerAccepted,
//                 ResourceOwnerAccepted, Locked, Disabled, Terminated }

contract Cyberspace is ChainlinkClient, Ownable, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    using SafeMath_Chainlink for uint256;
    using NodeNetwork for NodeNetwork.Network;
    NodeNetwork.Network network;


    
}

contract ResourceNode {
    enum StateType {created, enabled, disabled, terminated, pending}
    address public cyberspace;
}


contract NodeNetwork {
    using GraphLib for GraphLib.Graph;
    using HitchensUnorderedKeySetLib for HitchensUnorderedKeySetLib.Set;
    
    struct NodeMeta { address addr; }

    GraphLib.Graph public _graph;
    HitchensUnorderedKeySetLib.Set private _hashes;
    mapping(string => NodeMeta) public _nodes; // hashId => node

    
    function InsertNode(string hashid) public returns(address newNode){
        _hashes.insert(hashid);
        _nodes[hashid].addr = new ResourceNode();
        _graph.insertNode(toBytes32(_nodes[hashid].addr));
    }

    function LinkNodes(
        string hashidSource,
        string hashidTarget,
        uint256 importance
    ) public {
        require(
            _hashes.exists(hashidSource),
            "Cyberspace Network: Unknown source hash."
        );
        require(
            _hashes.exists(hashidTarget),
            "Cyberspace Network: Unknown target hash."
        );

        _graph.insertEdge(
            toBytes32(_nodes[hashidSource].addr),
            toBytes32(_nodes[hashidTarget].addr),
            importance
        );
    }

    function UnLinkNodes(
        string hashidSource,
        string hashidTarget,
        uint256 importance
    ) public {
        require(
            _hashes.exists(hashidSource),
            "Cyberspace Network: Unknown source hash."
        );
        require(
            _hashes.exists(hashidTarget),
            "Cyberspace Network: Unknown target hash."
        );

        _graph.removeEdge(
            toBytes32(_nodes[hashidSource].addr),
            toBytes32(_nodes[hashidTarget].addr),
            importance
        );
    }

    function GetLinkStats(string hashid)
        public
        view
        returns (uint256 uplinksCount, uint256 downlinksCount)
    {
        require(
            _hashes.exists(hashid),
            "Cyberspace Network: Unknown node hash."
        );
        (uplinksCount, downlinksCount) = _graph.node(
            toBytes32(_nodes[hashid].addr)
        );
    }

    function GetDownLinks(string hashid)
        public
        view
        returns (address[] memory)
    {
        require(
            _hashes.exists(hashid),
            "Cyberspace Network: Unknown source hash."
        );
        bytes32[] memory targets = _graph.nodeTargets(toBytes32(_nodes[hashid].addr));
        address[] memory targetsAddresses = new address[](targets.length);
        for (uint256 i = 0; i < targets.length; i++) {
            targetsAddresses[i] = toAddress(targets[i]);
        }
    }

    function RemoveNode(address nodeId) public {
        _graph.removeNode(toBytes32(nodeId)); // this will not be permited while edges exist, so iterate over unfollow until permissible.
    }

    function toBytes32(address a) private pure returns (bytes32) {
        return bytes32(uint256(uint160(a)));
    }

    function toAddress(bytes32 b) private pure returns (address) {
        return address(uint160(uint256(b)));
    }
}