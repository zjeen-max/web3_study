//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import { HelloWorld } from "./test.sol";

contract HelloWorldFactory {
    HelloWorld hw;
    HelloWorld[] hws;
    function createHelloword() public {
        hw = new HelloWorld();
        hws.push(hw);
    }
    // function getHelloWorldByIndex(uint256 _index) public view returns (HelloWorld){
    //     return hws[_index];
    // }
    function callSayHelloFromFactory(uint256 _id, uint256 _index) public view returns(string memory){
        return hws[_index].sayHello(_id);
    }
    function callSetHelloFromFactory(uint256 _id, uint256 _index,string memory str) public {
        hws[_index].setHello(_id,str);
    }
}