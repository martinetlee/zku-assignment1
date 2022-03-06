// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract MerkleTree {

    uint256 public leafCount;

    // height of the tree:
    // when there is 0 element, it is 0.
    // when there is 1 element, it is 1.
    // when there is 3 elements, it is 2.
    uint256 public height;

    mapping(uint256 => mapping(uint256 => bytes32)) public hashData;

    function root() public view returns (bytes32) {
        if(height == 0){
            return bytes32(0);
        } else {
            return hashData[height-1][0];
        }
    }

    function insert(bytes32 _newLeaf) public {
        // add new leaf to the lowest level
        hashData[0][leafCount] = _newLeaf;
        uint256 newLeafId = leafCount;
        leafCount++;

        uint256 currentLevel = 0;
        uint256 currentNodeId = newLeafId;

        // update the tree!
        // we start with the newest leaf and traverse to the root (or to the new root)
        while(true) {
            if(currentLevel != 0){
                // we calculate the hash of the current node
                refreshHash(currentLevel, currentNodeId);
            }

            // we have finished process if we are either the root or the new root!
            if((
                (currentNodeId == 0 && (currentLevel+1) == height) // when currentNode is root
            ) || (
                (currentNodeId == 0 && (currentLevel == height)) // we have exceeded the top
            )){
                // if it is the current root, then nothing will be updated
                // if we have exceeded the top, it means that this is the new root
                // and hence the height will be updated.
                height = currentLevel+1;
                break;
            }

            // iterate to parent
            currentNodeId = currentNodeId/2;
            currentLevel++;
        }
    }

    function refreshHash(uint256 level, uint256 id) public {
        require(level > 0, "invalid level");

        bytes32 leftChildHash = hashData[level-1][id * 2];
        bytes32 rightChildHash = hashData[level-1][id * 2+1];

        // Handling unbalanced merkle tree by duplication
        // https://medium.com/coinmonks/merkle-trees-concepts-and-use-cases-5da873702318
        if(rightChildHash == bytes32(0)) {
            hashData[level][id] = leftChildHash;
        } else {
            hashData[level][id] = keccak256(abi.encodePacked(leftChildHash, rightChildHash));
        }
    }

}