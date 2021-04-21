pragma solidity ^0.8.0;


// It would be possible to refactor for a version that uses address keys to avoid the type conversions in the test application. 
// Also possible to trim storage with relaxed integrity checks.

library GraphLib {
    
    using HitchensUnorderedKeySetLib for HitchensUnorderedKeySetLib.Set;
    
    struct EdgeStruct {
        bytes32 source;
        bytes32 target;
        uint weight;
    }
    
    struct NodeStruct {
        HitchensUnorderedKeySetLib.Set sourceEdgeSet; // in
        HitchensUnorderedKeySetLib.Set targetEdgeSet; // out
    }
    
    struct Graph {
        HitchensUnorderedKeySetLib.Set nodeSet;
        HitchensUnorderedKeySetLib.Set edgeSet;
        mapping(bytes32 => NodeStruct) nodeStructs;
        mapping(bytes32 => EdgeStruct) edgeStructs;
    }
    
    function insertNode(Graph storage g, bytes32 nodeId) internal {
        g.nodeSet.insert(nodeId);
    }
    
    function removeNode(Graph storage g, bytes32 nodeId) internal {
        NodeStruct storage n = g.nodeStructs[nodeId];
        require(n.sourceEdgeSet.count() == 0, "Graph: Remove source edges first.");
        require(n.targetEdgeSet.count() == 0, "Graph: Remove target edges first.");
        g.nodeSet.remove(nodeId);
        delete g.nodeStructs[nodeId];
    }
    
    function insertEdge(Graph storage g, bytes32 sourceId, bytes32 targetId, uint weight) internal returns(bytes32 edgeId) {
        require(g.nodeSet.exists(sourceId), "Graph: Unknown sourceId.");
        require(g.nodeSet.exists(targetId), "Graph: Unknown targetId.");
        edgeId = keccak256(abi.encodePacked(sourceId, targetId));
        EdgeStruct storage e = g.edgeStructs[edgeId];
        g.edgeSet.insert(edgeId);
        NodeStruct storage s = g.nodeStructs[sourceId];
        NodeStruct storage t = g.nodeStructs[targetId]; 
        s.targetEdgeSet.insert(edgeId);
        t.sourceEdgeSet.insert(edgeId);        
        e.source = sourceId;
        e.target = targetId;
        e.weight = weight;
    }
    
    function updateEdge(Graph storage g, bytes32 sourceId, bytes32 targetId, uint weight) internal {
        bytes32 edgeId = keccak256(abi.encodePacked(sourceId, targetId));
        require(g.edgeSet.exists(edgeId), "Graph: Unknown edge.");
        EdgeStruct storage e = g.edgeStructs[edgeId];
        e.weight = weight;
    }
    
    function removeEdge(Graph storage g, bytes32 sourceId, bytes32 targetId) internal {
        bytes32 edgeKey = keccak256(abi.encodePacked(sourceId, targetId));
        g.edgeSet.remove(edgeKey);
        delete g.edgeStructs[edgeKey];
        NodeStruct storage s = g.nodeStructs[sourceId];
        NodeStruct storage t = g.nodeStructs[targetId];
        s.targetEdgeSet.remove(edgeKey);
        t.sourceEdgeSet.remove(edgeKey);
    }
    
    function insertBetween(Graph storage g, bytes32 newNodeId, bytes32 sourceId, bytes32 targetId, uint sourceWeight, uint targetWeight) internal {
        removeEdge(g, sourceId, targetId);
        insertEdge(g, sourceId, newNodeId, sourceWeight);
        insertEdge(g, newNodeId, targetId, targetWeight);
    }  
    
    // View functioos
    
    function edgeExists(Graph storage g, bytes32 edgeId) internal view returns(bool exists) {
        return(g.edgeSet.exists(edgeId));
    }
    
    function edgeCount(Graph storage g) internal view returns(uint count) {
        return g.edgeSet.count();
    }
    
    function edgeAtIndex(Graph storage g, uint index) internal view returns(bytes32 edgeId) {
        return g.edgeSet.keyAtIndex(index);
    }
    
    function edgeSource(Graph storage g, bytes32 edgeId) internal view returns(bytes32 sourceId, uint weight) {
        require(edgeExists(g, edgeId), "Graph: Unknown edge.");
        EdgeStruct storage e = g.edgeStructs[edgeId];
        return(e.source, e.weight);
    } 
    
    function edgeTarget(Graph storage g, bytes32 edgeId) internal view returns(bytes32 targetId, uint weight) {
        require(edgeExists(g, edgeId), "Graph: Unknown edge.");
        EdgeStruct storage e = g.edgeStructs[edgeId];
        return(e.target, e.weight);
    } 
    
    // Nodes
    
    function nodeExists(Graph storage g, bytes32 nodeId) internal view returns(bool exists) {
        return(g.nodeSet.exists(nodeId));
    }
    
    function nodeCount(Graph storage g) internal view returns(uint count) {
        return g.nodeSet.count();
    }
    
    function node(Graph storage g, bytes32 nodeId) internal view returns(uint sourceCount, uint targetCount) {
        require(g.nodeSet.exists(nodeId), "Graph: Unknown node.");
        NodeStruct storage n = g.nodeStructs[nodeId];
        return(n.sourceEdgeSet.count(), n.targetEdgeSet.count());
    }

    function nodeTargets(Graph storage g, bytes32 nodeId) internal view returns(bytes32[] memory) {
        require(g.nodeSet.exists(nodeId), "Graph: Unknown node.");
        NodeStruct storage n = g.nodeStructs[nodeId];
        bytes32[] memory targets = new bytes32[](n.targetEdgeSet.count());

        for(uint i = 0; i < n.targetEdgeSet.count(); i++) {
            bytes32 targetId = n.targetEdgeSet.keyAtIndex(i);
            targets[i] = targetId;
        }
        return targets;
    }

    function nodeSources(Graph storage g, bytes32 nodeId) internal view returns(bytes32[] memory) {
        require(g.nodeSet.exists(nodeId), "Graph: Unknown node.");
        NodeStruct storage n = g.nodeStructs[nodeId];
        bytes32[] memory sources = new bytes32[](n.sourceEdgeSet.count());

        for(uint i = 0; i < n.sourceEdgeSet.count(); i++) {
            bytes32 sourceId = n.sourceEdgeSet.keyAtIndex(i);
            sources[i] = sourceId;
        }
        return sources;
    }
    
    function nodeSourceEdgeAtIndex(Graph storage g, bytes32 nodeId, uint index) internal view returns(bytes32 sourceEdge) {
        require(g.nodeSet.exists(nodeId), "Graph: Unknown node.");
        NodeStruct storage n = g.nodeStructs[nodeId];
        sourceEdge = n.sourceEdgeSet.keyAtIndex(index);
    }
    
    function nodeTargetEdgeAtIndex(Graph storage g, bytes32 nodeId, uint index) internal view returns(bytes32 targetEdge) {
        require(g.nodeSet.exists(nodeId), "Graph: Unknown node.");
        NodeStruct storage n = g.nodeStructs[nodeId];
        targetEdge = n.targetEdgeSet.keyAtIndex(index);
    }
}



contract GraphTest {
    
    using GraphLib for GraphLib.Graph;
    using HitchensUnorderedAddressSetLib for HitchensUnorderedAddressSetLib.Set;
    GraphLib.Graph userGraph;
    
    struct UserStruct {
        string name;
        // carry on with app concerns
    }
    
    HitchensUnorderedAddressSetLib.Set userSet;
    mapping(address => UserStruct) private userStructs;
    
    function newUser(address userId, string memory name) public {
        userSet.insert(userId);
        userStructs[userId].name = name;
        userGraph.insertNode(toBytes32(userId));
    }
    
    function removeUser(address userId) public {
        userGraph.removeNode(toBytes32(userId)); // this will not be permited while edges exist, so iterate over unfollow until permissible.
        delete userStructs[userId];
        userSet.remove(userId);
    }
    
    function updateUser(address userId, string memory name) public {
        require(userSet.exists(userId), "GraphTest: Unknown user.");
        userStructs[userId].name = name;
    }
    
    function follow(address sourceId, address targetId, uint importance) public {
        require(userSet.exists(sourceId), "GraphTest: Unknown follower.");
        require(userSet.exists(targetId), "GraphTest: Unknown target.");
        userGraph.insertEdge(toBytes32(sourceId), toBytes32(targetId), importance);
    }
    
    function unfollow(address sourceId, address targetId) public {
        require(userSet.exists(sourceId), "GraphTest: Unknown follower.");
        require(userSet.exists(targetId), "GraphTest: Unknown target.");
        userGraph.removeEdge(toBytes32(sourceId), toBytes32(targetId));
    }
    
    function adjustFollow(address sourceId, address targetId, uint importance) public {
        userGraph.updateEdge(toBytes32(sourceId), toBytes32(targetId), importance);
    }
    
    // view functions
    
    function userCount() public view returns(uint count) {
        count = userSet.count();
    }
    
    function userAtIndex(uint index) public view returns(address userId) {
        userId = userSet.keyAtIndex(index);
    }
    
    function userInfo(address userId) public view returns(string memory name, uint followerCount, uint followingCount) {
        require(userSet.exists(userId), "GraphTest: Unknown user.");
        (followerCount, followingCount) = userGraph.node(toBytes32(userId));
        name = userStructs[userId].name;
    }
    
    function userFollowerAtIndex(address userId, uint index) public view returns(address followerId, uint importance) {
        require(userSet.exists(userId), "GraphTest: Unknown user.");
        bytes32 edgeId = userGraph.nodeSourceEdgeAtIndex(toBytes32(userId), index);
        (bytes32 source, uint weight) = userGraph.edgeSource(edgeId);
        importance = weight;
        followerId = toAddress(source);
    }
    
    function userFollowingAtIndex(address userId, uint index) public view returns(address followingId, uint importance) {
        require(userSet.exists(userId), "GraphTest: Unknown user.");
        bytes32 edgeId = userGraph.nodeTargetEdgeAtIndex(toBytes32(userId), index);
        (bytes32 target, uint weight) = userGraph.edgeTarget(edgeId);
        importance = weight;
        followingId = toAddress(target);
    }
    
    // Debugging
    
    /*
    
    function edgeCount() public view returns(uint) {
        return userGraph.edgeCount();
    }
    
    function edgeAtIndex(uint index) public view returns(bytes32) {
        return userGraph.edgeAtIndex(index);
    }
    
    function edge(bytes32 edgeId) public view returns(bytes32 sourceId, bytes32 targetId, uint weight) {
        (sourceId, targetId, weight) = userGraph.edge(edgeId);
    }
    
    function edgeIdHelper(address source, address target) public pure  returns(bytes32 edgeId) {
        return(keccak256(abi.encodePacked(toBytes32(source), toBytes32(target))));
    }
    
    */
    
    // pure functions, because the graph was set up for bytes32 keys
    
    function toBytes32(address a) private pure returns(bytes32) {
        return bytes32(uint(uint160(a)));
    }
    
    function toAddress(bytes32 b) private pure returns(address) {
        return address(uint160(uint(b)));
    }
}


library HitchensUnorderedAddressSetLib {
    
    struct Set {
        mapping(address => uint) keyPointers;
        address[] keyList;
    }
    
    function insert(Set storage self, address key) internal {
        require(key != address(0), "UnorderedKeySet(100) - Key cannot be 0x0");
        require(!exists(self, key), "UnorderedAddressSet(101) - Address (key) already exists in the set.");
        self.keyList.push(key);
        self.keyPointers[key] = self.keyList.length-1;
    }
    
    function remove(Set storage self, address key) internal {
        require(exists(self, key), "UnorderedKeySet(102) - Address (key) does not exist in the set.");
        address keyToMove = self.keyList[count(self)-1];
        uint rowToReplace = self.keyPointers[key];
        self.keyPointers[keyToMove] = rowToReplace;
        self.keyList[rowToReplace] = keyToMove;
        delete self.keyPointers[key];
        self.keyList.pop();
    }
    
    function count(Set storage self) internal view returns(uint) {
        return(self.keyList.length);
    }
    
    function exists(Set storage self, address key) internal view returns(bool) {
        if(self.keyList.length == 0) return false;
        return self.keyList[self.keyPointers[key]] == key;
    }
    
    function keyAtIndex(Set storage self, uint index) internal view returns(address) {
        return self.keyList[index];
    }
    
    function nukeSet(Set storage self) public {
        delete self.keyList;
    }
}


library HitchensUnorderedKeySetLib {
    
    struct Set {
        mapping(bytes32 => uint) keyPointers;
        bytes32[] keyList;
    }
    
    function insert(Set storage self, bytes32 key) internal {
        require(key != 0x0, "UnorderedKeySet(100) - Key cannot be 0x0");
        require(!exists(self, key), "UnorderedKeySet(101) - Key already exists in the set.");
        self.keyList.push(key);
        self.keyPointers[key] = self.keyList.length-1;
    }
    
    function remove(Set storage self, bytes32 key) internal {
        require(exists(self, key), "UnorderedKeySet(102) - Key does not exist in the set.");
        bytes32 keyToMove = self.keyList[count(self)-1];
        uint rowToReplace = self.keyPointers[key];
        self.keyPointers[keyToMove] = rowToReplace;
        self.keyList[rowToReplace] = keyToMove;
        delete self.keyPointers[key];
        self.keyList.pop();
    }
    
    function count(Set storage self) internal view returns(uint) {
        return(self.keyList.length);
    }
    
    function exists(Set storage self, bytes32 key) internal view returns(bool) {
        if(self.keyList.length == 0) return false;
        return self.keyList[self.keyPointers[key]] == key;
    }
    
    function keyAtIndex(Set storage self, uint index) internal view returns(bytes32) {
        return self.keyList[index];
    }
    
    /*function nukeSet(Set storage self) public {
        delete self.keyList;
    }*/
}

contract HitchensUnorderedKeySet {
    
    using HitchensUnorderedKeySetLib for HitchensUnorderedKeySetLib.Set;
    HitchensUnorderedKeySetLib.Set set;
    
    event LogUpdate(address sender, string action, bytes32 key);
    
    function exists(bytes32 key) public view returns(bool) {
        return set.exists(key);
    }
    
    function insert(bytes32 key) public {
        set.insert(key);
        emit LogUpdate(msg.sender, "insert", key);
    }
    
    function remove(bytes32 key) public {
        set.remove(key);
        emit LogUpdate(msg.sender, "remove", key);
    }
    
    function count() public view returns(uint) {
        return set.count();
    }
    
    function keyAtIndex(uint index) public view returns(bytes32) {
        return set.keyAtIndex(index);
    }
    
    /*function nukeSet() public {
        set.nukeSet();
    }*/
}
