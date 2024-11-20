//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
contract FundMe{
    mapping(address => uint256) public fundersToAmount;
    uint256 MINIMUM_VALUE = 1 * 10 ** 18;//wei(ETH) --一般使用USD
    function fund() external payable{
        require(msg.value >= MINIMUM_VALUE, "send more ETH");
        fundersToAmount[msg.sender] = msg.value;
    }
    // 预言机
    function getChainlinkDataFeedLatestAnser()public view returns(int){

    }
}