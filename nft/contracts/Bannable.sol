// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract Bannable is Ownable {
   mapping(address => bool) public blacklist;

   function ban(address _address) public onlyOwner {
      blacklist[_address] = true;
   }

   function unban(address _address) public onlyOwner {
      blacklist[_address] = false;
   }

   modifier whenNotBanned() {
      require(!banned(), "address is banned");
      _;
   }

   modifier whenBanned() {
      require(banned(), "address is not banned");
      _;
   }

   function banned() public view returns (bool) {
      return blacklist[msg.sender];
   }
}