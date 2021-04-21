pragma solidity >=0.4.22 <0.9.0;

import {GraphLib, HitchensUnorderedKeySetLib} from "./lib/graph.sol";
import "./lib/graph.sol";
import "chainlink/contracts/ChainlinkClient.sol";
import "chainlink/contracts/vendor/Ownable.sol";
import {
    SafeMath as SafeMath_Chainlink
} from "chainlink/v0.5/contracts/vendor/SafeMath.sol";

// enum StatePolicyType { PendingReview, Healthy, UnHealthy, Modified, 
//                 PendingInspection, Inspected, CommisionerAccepted, 
//                 ResourceOwnerAccepted, Locked, Disabled, Terminated }

contract Cyberspace is ChainlinkClient, Ownable {
    using SafeMath_Chainlink for uint256;
    using GraphLib for GraphLib.Graph;    
    using HitchensUnorderedKeySetLib for HitchensUnorderedKeySetLib.Set;

    address admin;    
    GraphLib.Graph network;
    struct NodeMeta { address addr; uint sources; uint targets; }       
        
    mapping(string => NodeMeta) private _nodes;  // hashId => node 
    HitchensUnorderedKeySetLib.Set _hashset;
    
    function NewNode(string hashid) public {        
        _hashset.insert(hashid);                 
        _nodes[hashid].addr = new ResourceNode();
        _nodes[hashid].sources = 0;
        _nodes[hashid].targets = 0;        
        network.insertNode(toBytes32(_nodes[hashid].addr));        
    }

    function LinkNodes(string sourceHash, string targetHash, uint importance) public {
        require(_hashset.exists(sourceHash), "Cyberspace Network: Unknown source hash.");
        require(_hashset.exists(targetHash), "Cyberspace Network: Unknown target hash.");
       
        network.insertEdge(
            toBytes32(_nodes[sourceHash].addr), 
            toBytes32(_nodes[targetHash].addr), 
            importance);
        
        _nodes[sourceHash].targets++;
        _nodes[targetHash].sources++;

    }

    function UnLinkNodes(string sourceHash, string targetHash, uint importance) public {
        require(_hashset.exists(sourceHash), "Cyberspace Network: Unknown source hash.");
        require(_hashset.exists(targetHash), "Cyberspace Network: Unknown target hash.");
        
        network.removeEdge(
            toBytes32(_nodes[sourceHash].addr), 
            toBytes32(_nodes[targetHash].addr), 
            importance);
        
        _nodes[sourceHash].targets--;
        _nodes[targetHash].sources--;
    }

    function GetLinkStats(string hashid) public view returns(uint uplinksCount, uint downlinksCount) {
        require(_hashset.exists(hashid), "Cyberspace Network: Unknown node hash.");
        (uplinksCount, downlinksCount) = network.node(toBytes32(hashid));        
    }

    function GetDownLinks(string hashid) public view returns(address[] targets, uint importance) {
        require(_hashset.exists(sourceHash), "Cyberspace Network: Unknown source hash.");
        (uint uplinksCount, uint downlinksCount) = GetLinkStats(hashid);
         
         bytes32 edgeId = network.nodeTargetEdgeAtIndex(toBytes32(_hashset[sourceHash].addr), index);
        (bytes32 target, uint weight) = userGraph.edgeTarget(edgeId);
        network.insertEdge(
            toBytes32(_nodes[sourceHash].addr), 
            toBytes32(_nodes[targetHash].addr), 
            importance);
    }

    function userFollowingAtIndex(address userId, uint index) public view returns(address followingId, uint importance) {
        require(userSet.exists(userId), "GraphTest: Unknown user.");
        bytes32 edgeId = userGraph.nodeTargetEdgeAtIndex(toBytes32(userId), index);
        (bytes32 target, uint weight) = userGraph.edgeTarget(edgeId);
        importance = weight;
        followingId = toAddress(target);
    }

    

    function RemoveNode(address nodeId) public {
        network.removeNode(toBytes32(nodeId)); // this will not be permited while edges exist, so iterate over unfollow until permissible.
    
    }
    function toBytes32(address a) private pure returns(bytes32) {
        return bytes32(uint(uint160(a)));
    }
    
    function toAddress(bytes32 b) private pure returns(address) {
        return address(uint160(uint(b)));
    }
}


contract ResourceNode { 
    enum StateType {created, enabled, disabled, terminated, pending} 
    address public cyberspace;
}
