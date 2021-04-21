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

contract Cyberspace is ChainlinkClient, Ownable, AccessControl  {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    using SafeMath_Chainlink for uint256;
    using GraphLib for GraphLib.Graph;    
    using HitchensUnorderedKeySetLib for HitchensUnorderedKeySetLib.Set;

    GraphLib.Graph network;
    struct NodeMeta { address addr; uint sources; uint targets; }       
        
    mapping(string => NodeMeta) private _nodes;  // hashId => node 
    HitchensUnorderedKeySetLib.Set _hashset;
    
    function InsertNode(string hashid) public {        
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
        (uplinksCount, downlinksCount) = network.node(toBytes32(_nodes[hashid].addr));    
    }

    function GetDownLinks(string hashid) public view returns(address[] downlinks) {
        require(_hashset.exists(hashid), "Cyberspace Network: Unknown source hash.");
        bytes32[] targets = network.nodeTargets(toBytes32(_nodes[hashid].addr));
        
        downlinks = new address[](targets.length);
        for(uint i = 0; i < targets.length; i++) {
            addresses[i] = toAddress(targets[i]);
        }
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
