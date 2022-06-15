// SPDX-License-Identifier: MIT

// Solidity 版本
pragma solidity ^0.8.8;

// 引入合约/库
import "./PriceConverter.sol";
import "hardhat/console.sol";

// 错误码
error FundMe__NotOwner();
error FundMe__NotEnoughFunds();
error FundMe__WithdralFailed();

// 接口、库、合约

// 必要注释以自动生成文档
/** @title A contract for crowd funding
 *   @author Yu ZHANG
 *   @notice This contract is a demo for a sample funding contracts
 *   @dev This implements price feeds as our library
 */
contract FundMe {
    // 声明类型
    using PriceConverter for uint256;

    // 状态变量
    mapping(address => uint256) public s_addressToAmountFunded;
    address[] public s_funders;
    address public immutable i_owner;
    uint256 public constant MINIMUM_USD = 50 * 1e10;
    AggregatorV3Interface public s_priceFeed;

    // 事件

    // 函数修饰符
    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Not owner");
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    // 函数顺序
    // 1. constructor
    // 2. receive
    // 3. fallback
    // 4. external
    // 5. public
    // 6. internal
    // 7. private
    // 8. view / pure

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /**
     *   @notice This fuction is used to receive funds from participants
     *   @dev This implements price feeds as our library
     */
    function fund() public payable {
        // require(
        //     msg.value.getConversionRate() > MINIMUM_USD,
        //     "Not Enough Money"
        // );

        if (msg.value.getConversionRate(s_priceFeed) < MINIMUM_USD) {
            revert FundMe__NotEnoughFunds();
        }
        // console.log(">>> MINIMUM_USD:", MINIMUM_USD);
        // console.log(">>> Funding:", msg.value.getConversionRate(s_priceFeed));

        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            s_addressToAmountFunded[s_funders[funderIndex]] = 0;
        }

        s_funders = new address[](0);

        // transfer
        payable(msg.sender).transfer(address(this).balance);

        // send
        bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Withdraw Failed");
        if (!sendSuccess) {
            revert FundMe__WithdralFailed();
        }

        // call
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        // require(callSuccess, "Withdraw Failed");
        if (!callSuccess) {
            revert FundMe__WithdralFailed();
        }
    }
}
