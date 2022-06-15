// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract SimpleStorage {
    uint256 public favoriteNumber;
    event storedNumber(
        uint256 indexed oldNumber,
        uint256 indexed newNumber,
        uint256 addNumber,
        address sender
    );

    function store(uint256 newFavoriteNumber) public {
        emit storedNumber(
            favoriteNumber,
            newFavoriteNumber,
            newFavoriteNumber + favoriteNumber,
            msg.sender
        );
        favoriteNumber = newFavoriteNumber;
    }

    function retrieve() public view returns (uint256) {
        return favoriteNumber;
    }
}
