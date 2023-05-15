// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./VRFv2Consumer.sol";
import "./VRFv2ConsumerLibrary.sol";

contract BlackjackGame {
    address public player;
    address public dealer;
    uint256 public playerBalance;
    uint256 public dealerBalance;
    uint256 public betAmount;
    uint256 public playerScore;
    uint256 public playerEarnings;
    uint256 public dealerScore;
    uint256 internal p_playerScore;
    uint256 internal p_dealerScore;
    bool public playerTurn;
    VRFv2Consumer public consumer;
    uint256 public requestId;
    uint256[] public randomNumber;

    using VRFv2ConsumerLibrary for VRFv2ConsumerLibrary.State;
    VRFv2ConsumerLibrary.State public state;
    constructor(address consumerAddress) {
        player = msg.sender;
        dealer = address(this);
        playerBalance = 1000;
        dealerBalance = 1000000;
        betAmount = 0;
        playerScore = 0;
        dealerScore = 0;
        playerEarnings = 0;
        p_dealerScore = 0;
        p_playerScore = 0;
        playerTurn = true;
        consumer = VRFv2Consumer(consumerAddress);
        requestId = consumer.requestRandomWords();
    }
    


    function fulfillRandomness() public {

        uint256[] memory randomWords = VRFv2ConsumerLibrary.getRandomness(consumer, requestId);
        randomNumber = randomWords;
        state.initialize(randomNumber[0]);

    }

    // In place of your random function
   
    
    function placeBet(uint256 amount) public {
        require(playerBalance >= amount, "Insufficient balance");
        require(dealerBalance >= amount, "Insufficient balance");
        require(amount > 0, "Bet amount should be greater than zero");

        betAmount = amount;
        playerBalance -= amount;
        dealerBalance -= amount;

        // Deal two cards to the player and one to the dealer
        playerScore += getRandomCard();
        playerScore += getRandomCard();
        dealerScore += getRandomCard();

        if (playerScore == 21) {
            endGame("Player wins!");
        }
        if (playerScore > 21) {
            endGame("Dealer wins!");
        }
    }

    function hit() public {
        require(playerTurn, "It's not player's turn");

        uint256 card = getRandomCard();
        playerScore += card;

        if (playerScore > 21) {
            endGame("Dealer wins!");
        }

    }

    function stand() public{
        require(playerTurn, "It's not player's turn");

        playerTurn = false;

        // Dealer draws cards until the score is at least 17
        while (dealerScore < 17) {
            uint256 card = getRandomCard();
            dealerScore += card;
        }

        if (dealerScore > 21) {
            
            endGame("Player wins!");
            
        } else if (dealerScore >= playerScore) {
            endGame("Dealer wins!");
            
        } else {
            endGame("Player wins!");
         
        }
    }
    //  function testGetRandNo(uint n) public returns (uint) {
    //     if (state.length < state.iterator){
    //         state.rehash();
    //     }
    //     return state.getRandNo(n);
    // }


    function getRandomCard() private  returns (uint256) {
        if (state.length < state.iterator){
            state.rehash();
        }
        return state.getRandNo(13) + 1;
    }

    function endGame(string memory message) private {
        if (keccak256(abi.encodePacked(message)) == keccak256(abi.encodePacked("Player wins!"))) {
            playerBalance += 2 * betAmount;
        } else if (keccak256(abi.encodePacked(message)) == keccak256(abi.encodePacked("Dealer wins!"))) {
            dealerBalance += 2 * betAmount;
        } else {
            playerBalance += betAmount;
            dealerBalance += betAmount;
        }
        p_playerScore = playerScore;
        p_dealerScore = dealerScore;
        playerScore = 0;
        dealerScore = 0;
        betAmount = 0;
        playerTurn = true;
    }
    function resetGame() external {
        playerScore = 0;
        dealerScore = 0;
        betAmount = 0;
        playerTurn = true;
    }
    
    
    function whoWon() public view returns (string memory, uint256, uint256) {
    if (p_playerScore > 21) {
        return ("Dealer wins!", p_dealerScore, p_playerScore);
    } else if (p_dealerScore > 21) {
        return ("Player wins!", p_playerScore, p_dealerScore);
    } else if (p_dealerScore >= p_playerScore) {
        return ("Dealer wins!", p_dealerScore, p_playerScore);
    } else {
        return ("Player wins!", p_playerScore, p_dealerScore);
    }
}

}

