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

    address public owner;
    //时间锁
    uint256 deploymentTimestamp; //开始时间
    uint256 lockTime; // 锁定时间


    constructor(uint256 _lockTime) {
        //设置eth的spolice 测试网 eth兑usd的合约地址
        dataFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        owner = msg.sender;
        lockTime = _lockTime;
        // 区块的时间
        deploymentTimestamp = block.timestamp;
    }
    function fund() external payable{
        require(convertEthToUsd(msg.value) >= MINIMUM_VALUE, "send more ETH");
        require(block.timestamp < deploymentTimestamp + lockTime,"window si closed");
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
    // 判断是否是自己
    function transferOwenerShip(address newOwner) public {
        require(msg.sender == owner,"this function can only be called by owner");
        owner = newOwner;
    }
    // 查看筹集资金是否大于1000,大于则提取ETH
    function getFund() external {
        require(convertEthToUsd(address(this).balance) >= TARGET,"Target is not reached");
        require(msg.sender == owner,"there is no fund for you");
        require(block.timestamp >= deploymentTimestamp+lockTime,"window is close");
        //call 提取
        bool success;
        (success,)=payable(msg.sender).call{value: address(this).balance}(""); 
        require(success,"transfer tx failed");
        fundersToAmount[msg.sender] = 0;
    }
    function refund() external {
        require(convertEthToUsd(address(this).balance)<TARGET,"target is reached");
        require(fundersToAmount[msg.sender]!=0,"ther is no fund for you");
        require(block.timestamp >= deploymentTimestamp+lockTime,"window is close");
        bool success;
        (success,)=payable(msg.sender).call{value:fundersToAmount[msg.sender]}("");
        require(success,"transfer tx failed");
        // 归零
        fundersToAmount[msg.sender] = 0;
    }
}