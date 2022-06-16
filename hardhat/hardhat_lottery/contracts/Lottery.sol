// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

// 引用
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

// 错误码
error Lottery__NotEnoughEntranceFee();
error Lottery__NotOwner();
error Lottery__SendFailed();

/**
 * @title Lottery Smart Contract
 * @author Yu ZHANG
 * @dev 1. Enter(Pay at least 0.1 ETH)
 * @dev 2. Pick random winner - Chainlink Oracle
 * @dev 3. Automatically run - Chainlink Keeper
 */
contract Lottery is VRFConsumerBaseV2 {
    // 状态变量
    address private immutable i_owner;
    uint256 private immutable i_entranceFee;
    address payable[] private s_players;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_keyHash;
    uint64 private immutable i_subscriptionId;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private immutable i_callbackGasLimit;
    uint32 private constant NUM_WORDS = 1;

    // Lottery 变量
    address private s_recentWinner;

    // 事件
    event LotteryEnter(address indexed player);
    event RequestLotteryWinner(uint256 indexed requestId);
    event WinnerPicked(address indexed winner);

    // 函数修饰符
    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert Lottery__NotOwner();
        }
        _;
    }

    // 构造函数
    constructor(
        address vrfCoordinatorV2,
        uint256 entranceFee,
        bytes32 keyHash,
        uint64 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_owner = msg.sender;
        i_entranceFee = entranceFee;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_keyHash = keyHash;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
    }

    // external 函数
    /**
     * @notice For requesting the random number
     * @dev 1. Request the random number
     * @dev 2. Do something with the random number
     */
    function requestRandomWinner() external {
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_keyHash,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        emit RequestLotteryWinner(requestId);
    }

    // public 函数
    function enterLottery() public payable {
        if (msg.value < i_entranceFee) {
            revert Lottery__NotEnoughEntranceFee();
        }
        s_players.push(payable(msg.sender));
        emit LotteryEnter(msg.sender);
    }

    // internal 函数
    /**
     * @notice For get the random number
     */
    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        (bool sendSuccess, ) = recentWinner.call{value: address(this).balance}("");
        if (!sendSuccess) {
            revert Lottery__SendFailed();
        }
        emit WinnerPicked(recentWinner);
    }

    // view / pure 函数
    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    function getPlayers(uint256 index) public view returns (address) {
        return s_players[index];
    }

    function getRecentWinner() public view returns (address) {
        return s_recentWinner;
    }
}
