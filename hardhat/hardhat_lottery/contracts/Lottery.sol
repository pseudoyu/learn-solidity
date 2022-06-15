// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

// Error Code
error Lottery__NotEnoughEntranceFee();

/**
 * @title Lottery Smart Contract
 * @author Yu ZHANG
 * @dev 1. Enter(Pay at least 0.1 ETH) 2. Pick random winner - Chainlink Oracle 3. Automatically run - Chainlink Keeper
 */
contract Lottery {
    // State Variables
    uint256 private immutable i_entranceFee;
    address payable[] private s_players;

    // Events
    event LotteryEnter(address indexed player);

    // Constructor
    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }

    function enterLottery() public payable {
        if (msg.value < i_entranceFee) {
            revert Lottery__NotEnoughEntranceFee();
        }
        s_players.push(payable(msg.sender));
        emit LotteryEnter(msg.sender);
    }

    // function pickRandomWinner() public {}

    // view / pure functions
    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    function getPlayers(uint256 index) public view returns (address) {
        return s_players[index];
    }
}
