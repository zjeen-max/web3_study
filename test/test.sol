//SPDX-License-Identifier: UNLICENSED
//pragma solidity ^0.8.28;
contract HelloWord{
    string name = "aaa11";
    function getHello() view public returns(string memory){
        return name;
    }
    function changeName(string memory _name) public{
        name = _name;
    }
}