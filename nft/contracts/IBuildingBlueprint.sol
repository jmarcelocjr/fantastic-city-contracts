// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IBuildingBlueprint {
   function getBlueprintDetail(uint256 id) external view returns(
      string memory,
      uint256,
      uint256,
      uint256,
      uint256,
      uint256,
      uint256,
      bool
   );

   function getTotalBlueprints() external view returns(uint256);
}