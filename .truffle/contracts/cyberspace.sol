pragma solidity >=0.4.22 <0.9.0;

import {GraphLib} from "./lib/graph.sol";
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
    using HitchensUnorderedAddressSetLib for HitchensUnorderedAddressSetLib.Set;
    GraphLib.Graph network;

    
    struct node { 
        hash id;        
    }

    mapping(address => node) private nodes;  
    HitchensUnorderedAddressSetLib.Set nodeSet;
       
    function createNode(address nodeId) public {
        require(network.nodeExists(toBytes32(nodeId)) == false, "Network: node already exists.");        
        
        network.insertNode(toBytes32(nodeId));
        return new AssetNode();
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


contract AssetNode { 
    enum StateType {created, enabled, disabled, terminated, pending} 
    address public cyberspace;

    
}
