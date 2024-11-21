import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
// 1. 创建一个收款函数
// 2. 记录投资人并且查看
// 3. 在锁定期内，达到目标值，生产商可以提款
// 4. 在锁定期内,没有达到目标值,投资人在锁定期以后退款
contract FundMe{
    mapping(address => uint256) public fundersToAmount;
    uint256 MINIMUM_VALUE = 100 * 10 ** 18;//wei(ETH) --一般使用USD
    // 合约类型 internal 合约内部调用
    AggregatorV3Interface internal dataFeed;

    uint256 constant TARGET = 1000 * 10**18;

    constructor() {
        //设置eth的spolice 测试网 eth兑usd的合约地址
        dataFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
    }
    function fund() external payable{
        require(convertEthToUsd(msg.value) >= MINIMUM_VALUE, "send more ETH");
        fundersToAmount[msg.sender] = msg.value;
    }
    // 预言机 https://docs.chain.link/ 
    // 获取 ETH 实时的USD
    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }
    // 把ETH转为USD
    function convertEthToUsd(uint256 ethAmount) internal view returns (uint256){
        /* 
        ETH / USD precision = 10**8
         x/ ETH presion = 10**18
        */
        uint256 ethPrice = uint256(getChainlinkDataFeedLatestAnswer());
        return ethAmount * ethPrice/(10**8);
    }

    // 查看筹集资金是否大于1000
    function getFund() external view {
        
        require(convertEthToUsd(address(this).balance) >= TARGET,"Target is not reached");
    }
}