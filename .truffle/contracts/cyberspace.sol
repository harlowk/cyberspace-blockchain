pragma solidity ^0.8.0;

import "chainlink/contracts/Oracle.sol";
import "chainlink/contracts/ChainlinkClient.sol";
import "chainlink/contracts/vendor/Ownable.sol";
import "chainlink/contracts/interfaces/LinkTokenInterface.sol";
import "chainlink/contracts/interfaces/AggregatorInterface.sol";

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
}


contract CyberspaceSignatory is CyberspaceNetworkTree {

}
