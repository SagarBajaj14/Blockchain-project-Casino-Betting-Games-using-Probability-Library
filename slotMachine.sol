// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./VRFv2Consumer.sol";
import "./VRFv2ConsumerLibrary.sol";


pragma solidity ^0.8.0;



contract SlotMachine {
    uint256 public BET_AMOUNT; // Amount to bet for each play
    uint256 private winningAmount;
    VRFv2Consumer public consumer;
    uint256 public requestId;
    uint256[] public randomNumber;
    using VRFv2ConsumerLibrary for VRFv2ConsumerLibrary.State;
    VRFv2ConsumerLibrary.State private state;

    constructor(address consumerAddress) {
        consumer = VRFv2Consumer(consumerAddress);
        requestId = consumer.requestRandomWords();
    }


    function fulfillRandomness() public {

        uint256[] memory randomWords = VRFv2ConsumerLibrary.getRandomness(consumer, requestId);
        randomNumber = randomWords;
        state.initialize(randomNumber[0]);

    }

    event PlayResult(address indexed player, bool indexed isWinner, uint256 winnings);

    function placeBet() external payable {
        BET_AMOUNT = msg.value;
        require(msg.value == BET_AMOUNT, "Incorrect bet amount");
    }

    function play() external {
        uint256 randomNumber = _getRandomNumber();
        winningAmount = _generateWinningAmount(randomNumber);

        if (winningAmount > 0) {
            (bool success, ) = payable(msg.sender).call{value: winningAmount}("");
            require(success, "Failed to send winnings");
        }

        emit PlayResult(msg.sender, winningAmount > 0, winningAmount);
    }

    function getWinningAmount() external view returns (uint256) {
        return winningAmount;
    }

    function _generateWinningAmount(uint256 randomNumber) private  returns (uint256) {
        // Calculate winnings based on the random number
        if (randomNumber >= 9000) {
            return BET_AMOUNT * 10; // Player wins 10 times the bet amount
        } else if (randomNumber >= 5000) {
            return BET_AMOUNT * 5; // Player wins 5 times the bet amount
        } else if (randomNumber >= 100) {
            return BET_AMOUNT * 2; // Player wins 2 times the bet amount
        } else {
            return 0; // Player loses
        }
    }

    function _getRandomNumber() private returns (uint256)
    {
        if (state.length < state.iterator)
        {
            state.rehash();
        }
        return state.getRandNo(10000);
    }
    
}
