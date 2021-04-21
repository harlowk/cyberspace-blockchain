// pragma solidity >=0.4.22 <0.9.0;


// struct IndexValue { uint keyIndex; uint value; }
// struct KeyFlag { uint key; bool deleted; }
// struct KeyValue { uint key; uint value; }
// struct HashSet {
//     mapping(string => IndexValue) data;
//     KeyFlag[] keys;
//     uint size;
// }

// library SetMap
// {    
//   function insert(set storage self, string key, uint value) returns (bool replaced)
//   {
//     uint keyIndex = self.data[key].keyIndex;
//     self.data[key].value = value;
//     if (keyIndex > 0)
//       return true;
//     else
//     {
//       keyIndex = keys.length++;
//       self.data[key].keyIndex = keyIndex + 1;
//       self.keys[keyIndex].key = key;
//       self.size++;
//       return false;
//     }
//   }
//   function remove(set storage self, string key) returns (bool success)
//   {
//     uint keyIndex = self.data[key].keyIndex;
//     if (keyIndex == 0)
//       return false;
//     delete self.data[key];
//     self.keys[keyIndex - 1].deleted = true;
//     self.size --;
//   }
//   function contains(set storage self, string key)
//   {
//     return self.data[key].keyIndex > 0;
//   }
//   function iterate_start(set storage self) returns (uint keyIndex)
//   {
//     return iterate_next(self, -1);
//   }
//   function iterate_valid(set storage self, uint keyIndex) returns (bool)
//   {
//     return keyIndex < self.keys.length;
//   }
//   function iterate_next(set storage self, uint keyIndex) returns (uint r_keyIndex)
//   {
//     keyIndex++;
//     while (keyIndex < self.keys.length && self.keys[keyIndex].deleted)
//       keyIndex++;
//     return keyIndex;
//   }
//   function iterate_get(set storage self, uint keyIndex) returns (KeyValue r)
//   {
//     r.key = self.keys[keyIndex].key;
//     r.value = self.data[key];
//   }

// }