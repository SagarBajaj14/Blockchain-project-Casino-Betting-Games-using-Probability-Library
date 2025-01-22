# Provably Fair Gaming: Randomness and Blockchain Integration for Casino Games

# Importance of Chainlink VRF

Verified random numbers are crucial in various applications, especially in blockchain-based systems where fairness and unpredictability are essential. By utilizing Chainlink's VRF, developers can obtain random numbers that are both provably fair and tamper-resistant.

# Project description

The probability library function generates a random number using Chainlink VRF. Multiple random numbers can be formed using the obtained random number by dividing it into bits and hashing the bits to obtain a new random number. The random number generated using probability library is called in the games of Slot Machine, Roulette and Black Jack. The implementation of each contract in solidity is provided in the code section. The VRFv2Consumer.sol is used to generate random number using Chainlink VRF and is referred from Chainlink documentation https://docs.chain.link/vrf/v2/subscription/examples/get-a-random-number.
