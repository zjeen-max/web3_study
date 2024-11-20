//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
contract HelloWord{
    struct Info {
        string phrase;
        uint256 id;
        address addr;
    }
    //Info[] infos;
    mapping(uint256=>Info) infoMapping;
   function sayHello(uint256 _id) public view returns(string memory){
    return addinfo(infoMapping[_id].phrase);
   }
   function setHello(uint256 _id,string memory str) public {
    Info memory info = Info(str,_id,msg.sender);
    infoMapping[_id]=info;
   }
   function addinfo(string memory str) internal pure returns(string memory){
    return string.concat(str, "from frank's contract.");
   }
}