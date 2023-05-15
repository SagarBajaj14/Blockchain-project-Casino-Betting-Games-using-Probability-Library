// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./VRFv2Consumer.sol";

library VRFv2ConsumerLibrary {
    struct State {
        uint randWord;
        uint vrfRandWord;
        uint length;
        uint iterator;
    }
    
    function initialize(State storage self, uint randWord) internal {

        self.randWord = randWord;
        self.vrfRandWord = randWord;
        self.length = 256; 
        self.iterator = 10;
    }

    function rehash(State storage self) internal {

        self.randWord = uint256(keccak256(abi.encodePacked(self.vrfRandWord)));
        self.vrfRandWord = uint256(keccak256(abi.encodePacked(self.vrfRandWord)));
        self.iterator = 10;
    }

    function getRandNo(State storage self, uint n) internal returns (uint) {
        uint16 rno = uint16(self.randWord) % 1024;
        self.randWord = self.randWord >> 10;
        self.iterator += 10;
        return rno % n;

    }
    
    function getRandomness(VRFv2Consumer consumer, uint256 requestId)
        internal view returns (uint256[] memory)
    {
        // Call the consumer contract's getRequestStatus function
        (bool fulfilled, uint256[] memory randomWords) =
            consumer.getRequestStatus(requestId);

        // If the request hasn't been fulfilled, return an empty array
        if (!fulfilled) {
            return new uint256[](0);
        }

        // Otherwise, return the random words
        return randomWords;
    }

    function getRequestStatus(VRFv2Consumer consumer, uint256 requestId)
        internal view returns (bool fulfilled, uint256[] memory randomWords)
    {
        // Call the consumer contract's getRequestStatus function
        (fulfilled, randomWords) = consumer.getRequestStatus(requestId);
    }


}
