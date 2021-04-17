pragma solidity ^0.8.0;

import {GraphLib} from "../libraries/graph/GraphLib.sol";
import "../libraries/graph/HitchensUnorderedAddressSet.sol";

contract CyberspaceGraph {
    using GraphLib for GraphLib.Graph;
    using HitchensUnorderedAddressSetLib for HitchensUnorderedAddressSetLib.Set;
    GraphLib.Graph graph;

    function toBytes32(address a) private pure returns(bytes32) {
        return bytes32(uint(uint160(a)));
    }
    
    function toAddress(bytes32 b) private pure returns(address) {
        return address(uint160(uint(b)));
    }
}