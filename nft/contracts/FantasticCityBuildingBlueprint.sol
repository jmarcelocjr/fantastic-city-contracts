// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IBuildingBlueprint.sol";

contract FantasticCityBuildingBlueprint is IBuildingBlueprint, Ownable {

   struct Blueprint {
      string  name;
      uint256 common;
      uint256 uncommon;
      uint256 rare;
      uint256 epic;
      uint256 legendary;
      uint256 value;
      bool disabled;
   }

   Blueprint[] public blueprints;

   function createBlueprint(
      string memory name,
      uint256 common,
      uint256 uncommon,
      uint256 rare,
      uint256 epic,
      uint256 legendary,
      uint256 value
   ) public onlyOwner {
      blueprints.push(
         Blueprint(
            name,
            common,
            uncommon,
            rare,
            epic,
            legendary,
            value,
            false
         )
      );
   }

   function disableBlueprint(uint256 id) public onlyOwner returns (bool) {
      require(!blueprints[id].disabled, "Blueprint already disabled");

      blueprints[id].disabled = true;

      return true;
   }

   function getBlueprintDetail(uint256 id) public override view returns(
      string memory,
      uint256,
      uint256,
      uint256,
      uint256,
      uint256,
      uint256,
      bool
   ) {
      Blueprint memory bp = blueprints[id];
      require(bp.value > 0, "This blueprint does not exist");
      return (
         bp.name,
         bp.common,
         bp.uncommon,
         bp.rare,
         bp.epic,
         bp.legendary,
         bp.value,
         bp.disabled
      );
   }

   function getTotalBlueprints() public override view returns(uint256) {
      return blueprints.length;
   }

   function updateValue(uint256 blueprintId, uint256 value) public onlyOwner {
      require(blueprints[blueprintId].value > 0, "This blueprint does not exist");
      blueprints[blueprintId].value = value;
   }

   function withdrawalToken(address contractAddress, address destination, uint256 amount) public onlyOwner {
      IERC20 tokenContract = IERC20(contractAddress);

      tokenContract.transfer(destination, amount);
   }
}