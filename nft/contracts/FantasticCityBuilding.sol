// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FantasticCityBuilding is ERC721, ERC721Enumerable, VRFConsumerBase, Pausable, Ownable {

   IERC20 public fcToken;
   address internal linkToken;
   bytes32 internal keyHash;
   uint256 public fee;

   struct Building {
      uint256 rarity;
      uint256 businessType;
      uint256 size;
      uint256 reputation;
      uint256 level;
   }

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

   Building[] public buildings;
   Blueprint[] public blueprints;

   mapping(address => mapping(uint256 => uint256)) public ownerBlueprints;

   mapping(bytes32 => address) public requestIdToSender;
   mapping(bytes32 => uint256) public requestIdBlueprintId;

   event newBuilding(bytes32 indexed requestId);

   constructor(address _fcToken, address _vrfCoordinator, address _linkToken, bytes32 _keyhash)
      VRFConsumerBase(_vrfCoordinator, _linkToken)
      ERC721("FantasticCityBuilding", "FCB")
   {
      fcToken = IERC20(_fcToken);
      linkToken = _linkToken;
      keyHash = _keyhash;
      fee = 0.1 * 10 ** 18;
   }

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

   function disableBlueprint(uint256 id) public onlyOwner returns(bool) {
      require(!blueprints[id].disabled, "Blueprint already disabled");

      blueprints[id].disabled = true;

      return true;
   }

   function getBlueprintDetail(uint256 id) public view returns(
      string memory,
      uint256,
      uint256,
      uint256,
      uint256,
      uint256,
      uint256
   ) {
      return (
         blueprints[id].name,
         blueprints[id].common,
         blueprints[id].uncommon,
         blueprints[id].rare,
         blueprints[id].epic,
         blueprints[id].legendary,
         blueprints[id].value
      );
   }

   function getOwnedBlueprints() public view returns(uint256[] memory, uint256[] memory) {
      return _getBlueprintsAddress(msg.sender);
   }

   function getBlueprintsFromAddress(address _address) public onlyOwner view returns(uint256[] memory, uint256[] memory) {
      return _getBlueprintsAddress(_address);
   }

   function _getBlueprintsAddress(address _address) internal view returns (uint256[] memory, uint256[] memory) {
      uint256[] memory ids = new uint256[](blueprints.length);
      uint256[] memory amount = new uint256[](blueprints.length);

      for (uint256 i = 0; i < blueprints.length; i++) {
         ids[i] = i;
         amount[i] = ownerBlueprints[_address][i];
      }

      return (
         ids,
         amount
      );
   }

   function buyBlueprint(uint256 id) public whenNotPaused returns (bool) {
      require(!blueprints[id].disabled || blueprints[id].value > 0, "Blueprint does not exist");

      fcToken.transferFrom(msg.sender, address(this), blueprints[id].value);

      ownerBlueprints[msg.sender][id]++;

      return true;
   }

   function build(uint256 blueprintId) public whenNotPaused returns (bytes32) {
      require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK");
      require(ownerBlueprints[msg.sender][blueprintId] > 0, "Not enough blueprint to build");

      ownerBlueprints[msg.sender][blueprintId]--;

      bytes32 requestId = requestRandomness(keyHash, fee);
      requestIdToSender[requestId] = msg.sender;
      requestIdBlueprintId[requestId] = blueprintId;

      emit newBuilding(requestId);

      return requestId;
   }

   function fulfillRandomness(bytes32 requestId, uint256 randomNumber) internal override {
      uint256[] memory randomNumbers = expandRandomness(randomNumber, 4);

      uint256 newId        = buildings.length;
      uint256 rarity       = getRarity(randomNumbers[0], blueprints[requestIdBlueprintId[requestId]]);
      uint256 businessType = getBusinessType(randomNumbers[1]);
      uint256 size         = getSize(randomNumbers[2]);

      buildings.push(
         Building(
            rarity,
            businessType,
            size,
            getReputation(rarity, businessType, size, randomNumbers[3]),
            1
         )
      );

      _safeMint(requestIdToSender[requestId], newId);
   }

   function expandRandomness(uint256 randomNumber, uint256 n) internal pure returns (uint256[] memory) {
      uint256[] memory expandedValues = new uint256[](n);

      for (uint256 i = 0; i < n; i++) {
         expandedValues[i] = uint256(keccak256(abi.encode(randomNumber, i)));
      }

      return expandedValues;
   }

   function getRarity(uint256 randomNumber, Blueprint memory blueprint) internal pure returns (uint256) {
      uint256 converted = randomNumber % 100;

      if (converted >= blueprint.legendary) {
         return 5;
      } else if (converted >= blueprint.epic) {
         return 4;
      } else if (converted >= blueprint.rare) {
         return 3;
      } else if (converted >= blueprint.uncommon) {
         return 2;
      }

      return 1;
   }

   function getSize(uint256 randomNumber) internal pure returns (uint256) {
      uint256 converted = randomNumber % 100;

      return converted < 59 ? 1 : (converted < 94 ? 2 : 3);
   }

   function getBusinessType(uint256 randomNumber) internal pure returns (uint256) {
      uint256 converted = randomNumber % 100;

      return converted < 49 ? 1 : (converted < 79 ? 2 : 3);
   }

   function getReputation(uint256 rarity, uint256 businessType, uint256 size, uint256 randomNumber) internal pure returns (uint256) {
      uint256[2] memory range = getRangeReputationByRarity(rarity);

      uint256 reputation = randomNumber % (range[1] + 1);
      reputation *= (1 + (businessType / 10) + (size / 10));

      return reputation < range[0] ? range[0] : (reputation > range[1] ? range[1] : reputation);
   }

   function getRangeReputationByRarity(uint256 rarity) internal pure returns (uint256[2] memory) {
      return [
         (rarity * 50) - 50 + 1,
         rarity * 50
      ];
   }

   function getBuildingDetail(uint256 tokenId) public view 
      returns (
         uint256,
         uint256,
         uint256,
         uint256,
         uint256
      )
   {
      return (
         buildings[tokenId].rarity,
         buildings[tokenId].businessType,
         buildings[tokenId].size,
         buildings[tokenId].reputation,
         buildings[tokenId].level
      );
   }

   function updateValue(uint256 blueprintId, uint256 value) public onlyOwner {
      blueprints[blueprintId].value = value;
   }

   function updateTokenAddress(address _fcToken) public onlyOwner {
      fcToken = IERC20(_fcToken);
   }

   function withdrawalToken(address contractAddress, address destination, uint256 amount) public onlyOwner {
      IERC20 tokenContract = IERC20(contractAddress);

      tokenContract.transfer(destination, amount);
   }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}