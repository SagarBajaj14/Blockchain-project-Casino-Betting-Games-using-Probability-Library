// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./VRFv2Consumer.sol";
import "./VRFv2ConsumerLibrary.sol";


contract Roulette {
    event BetPlaced(address indexed player, uint256 betAmount, uint256 betOption);
    event SpinResult(uint256 result, string resultDescription, address[] winners);

    VRFv2Consumer public consumer;
    uint256 public requestId;
    uint256[] public randomNumber;
    uint256 prev_randNo;
    string prev_colour;
    using VRFv2ConsumerLibrary for VRFv2ConsumerLibrary.State;
    VRFv2ConsumerLibrary.State public state;

    constructor(address consumerAddress) {
        consumer = VRFv2Consumer(consumerAddress);
        requestId = consumer.requestRandomWords();
    }

    


    uint256 private constant MAX_BET_AMOUNT = 10 ether;
    uint256 private constant MAX_NUM_PLAYERS = 10;

    enum BetOption { Number, Black, Red, HigherThan18, LowerThan18, Even, Odd }

    struct Bet {
        address player;
        uint256 amount;
        BetOption option;
    }

    Bet[] public bets;
    address[] public players;

    mapping(address => uint256) public playerBets;

    function fulfillRandomness() public {

        uint256[] memory randomWords = VRFv2ConsumerLibrary.getRandomness(consumer, requestId);
        randomNumber = randomWords;
        state.initialize(randomNumber[0]);

    }


    function placeBet(uint256 amount, BetOption option) external payable {
        require(amount > 0 && amount <= MAX_BET_AMOUNT, "Invalid bet amount");
        require(players.length < MAX_NUM_PLAYERS, "Maximum number of players reached");
        
        // require(msg.value == amount, "Invalid bet amount");

        Bet memory newBet = Bet(msg.sender, amount, option);
        bets.push(newBet);
        players.push(msg.sender);
        playerBets[msg.sender] = amount;

        emit BetPlaced(msg.sender, amount, uint256(option));
    }

    function spinWheel() external {
        require(bets.length > 0, "No bets placed");

        uint256 randomNo = generateRandomNumber();
        string memory resultDescription = getResultDescription(randomNo);

        address[] memory winners = determineWinners(randomNo);

        emit SpinResult(randomNo, resultDescription, winners);
        prev_randNo = randomNo;

        distributePrizes(winners);
        resetGame();
    }

    function generateRandomNumber() public returns (uint256) {
        if (state.length < state.iterator){
            state.rehash();
        }
        return state.getRandNo(37);
    }
    

    function getResultDescription(uint256 number) public returns (string memory) {
        if (number == 0) {
            prev_colour = "Green";
            return "Green 0";
        } else if (
            (number >= 1 && number <= 10) ||
            (number >= 19 && number <= 28)
        ) {
            prev_colour = "Red";
            return "Red";
        } else {
            prev_colour = "Black";
            return "Black";
        }
    }

    function win_number() public view returns(uint, string memory) {
        return (prev_randNo, prev_colour);
    }
    function determineWinners(uint256 number) private view returns (address[] memory) {
        address[] memory winners = new address[](players.length);
        uint256 winnerCount = 0;

        for (uint256 i = 0; i < players.length; i++) {
            Bet memory bet = bets[i];

            if (bet.option == BetOption.Number && bet.amount > 0 && bet.amount <= playerBets[bet.player]) {
                if (number == bet.amount) {
                    winners[winnerCount] = bet.player;
                    winnerCount++;
                }

                } else if (bet.option == BetOption.Red && ((number >= 1 && number <= 10) || (number >= 19 && number <= 28))) {
                    winners[winnerCount] = bet.player;
                    winnerCount++;
                } else if (bet.option == BetOption.Black && ((number >= 11 && number <= 18) || (number >= 29 && number <= 36))) {
                    winners[winnerCount] = bet.player;
                    winnerCount++;
                } else if (bet.option == BetOption.HigherThan18 && number > 18) {
                    winners[winnerCount] = bet.player;
                    winnerCount++;
                } else if (bet.option == BetOption.LowerThan18 && number < 19) {
                    winners[winnerCount] = bet.player;
                    winnerCount++;
                } else if (bet.option == BetOption.Even && number % 2 == 0) {
                    winners[winnerCount] = bet.player;
                    winnerCount++;
                } else if (bet.option == BetOption.Odd && number % 2 != 0) {
                    winners[winnerCount] = bet.player;
                    winnerCount++;
                }
            }

        address[] memory actualWinners = new address[](winnerCount);

        for (uint256 i = 0; i < winnerCount; i++) {
            actualWinners[i] = winners[i];
        }

        return actualWinners;
    }

    function distributePrizes(address[] memory winners) public {
        uint256 totalBetAmount = 0;

        for (uint256 i = 0; i < players.length; i++) {
            totalBetAmount += playerBets[players[i]];
        }

        if(winners.length >0){

            uint256 prizePerWinner = totalBetAmount / winners.length;

            for (uint256 i = 0; i < winners.length; i++) {
                if (winners[i] != address(0)) {
                    payable(winners[i]).transfer(prizePerWinner);
                }
            }
        }
    }

    function resetGame() public {
        for (uint256 i = 0; i < players.length; i++) {
            delete playerBets[players[i]];
        }

        delete bets;
        delete players;
    }
   
    
//     function displayWinnerOrLoser(address player) public view returns (string memory) {
//     for (uint256 i = 0; i < bets.length; i++) {
//         Bet memory bet = bets[i];
//         if (bet.player == player) {
//             if (bet.option == BetOption.Number && randomNumber[0] == bet.amount) {
//                 return "Congratulations! You are the winner.";
//             } else if (bet.option == BetOption.Red && ((randomNumber[0] >= 1 && randomNumber[0] <= 10) || (randomNumber[0] >= 19 && randomNumber[0] <= 28))) {
//                 return "Congratulations! You are the winner.";
//             } else if (bet.option == BetOption.Black && ((randomNumber[0] >= 11 && randomNumber[0] <= 18) || (randomNumber[0] >= 29 && randomNumber[0] <= 36))) {
//                 return "Congratulations! You are the winner.";
//             } else if (bet.option == BetOption.HigherThan18 && randomNumber[0] > 18) {
//                 return "Congratulations! You are the winner.";
//             } else if (bet.option == BetOption.LowerThan18 && randomNumber[0] < 19) {
//                 return "Congratulations! You are the winner.";
//             } else if (bet.option == BetOption.Even && randomNumber[0] % 2 == 0) {
//                 return "Congratulations! You are the winner.";
//             } else if (bet.option == BetOption.Odd && randomNumber[0] % 2 != 0) {
//                 return "Congratulations! You are the winner.";
//             } else {
//                 return "Sorry, you are a loser.";
//             }
//         }
//     }
//     return "No bet placed by the player.";
// }
}