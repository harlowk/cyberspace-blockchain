pragma solidity ^0.8.0;

import {PromisedCyberArtifact} from "./cyberspace-warrant.sol";
import {CyberspaceNetworkTree} from "./libraries/cyberspace-network-tree.sol";

enum StatePolicyType { PendingReview, Healthy, UnHealthy, Modified, 
                PendingInspection, Inspected, CommisionerAccepted, 
                ResourceOwnerAccepted, Locked, Disabled, Terminated }
// struct CyberPromise {
//     bytes32 uid;
//     bool signed;
// }
struct BondSignature {
    bytes32 uid;    
    bool signed;
    address signator;
    address promisor; // making the promise
    address promisee; // recieving the promise
    address[] observers; // those that can observe the bond.
    PromisedCyberArtifact promiseContract;
    StatePolicyType state;
}


contract CyberspaceSignatory is CyberspaceNetworkTree {

}
