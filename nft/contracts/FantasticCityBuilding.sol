// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IBuildingBlueprint.sol";

contract FantasticCityBuilding is ERC721, ERC721Enumerable, VRFConsumerBase, Pausable, Ownable {

   IERC20 public fcToken;
   IBuildingBlueprint public fcbBlueprint;
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

   Building[] public buildings;

   mapping(address => mapping(uint256 => uint256)) public ownerBlueprints;

   mapping(bytes32 => address) public requestIdToSender;
   mapping(bytes32 => uint256) public requestIdBlueprintId;

   event newBuilding(uint256 indexed id, address indexed _address);

   constructor(address _fcToken, address _fcbBlueprint, address _vrfCoordinator, address _linkToken, bytes32 _keyhash)
      VRFConsumerBase(_vrfCoordinator, _linkToken)
      ERC721("FantasticCityBuilding", "FCB")
   {
      fcToken = IERC20(_fcToken);
      fcbBlueprint = IBuildingBlueprint(_fcbBlueprint);
      linkToken = _linkToken;
      keyHash = _keyhash;
      fee = 0.1 * 10 ** 18;
   }

   function getOwnedBlueprints() public view returns (uint256[] memory, uint256[] memory) {
      return _getBlueprintsByAddress(msg.sender);
   }

   function getBlueprintsFromAddress(address _address) public onlyOwner view returns (uint256[] memory, uint256[] memory) {
      return _getBlueprintsByAddress(_address);
   }

   function _getBlueprintsByAddress(address _address) internal view returns (uint256[] memory, uint256[] memory) {
      uint256 totalBlueprint = fcbBlueprint.getTotalBlueprints();
      uint256[] memory ids = new uint256[](totalBlueprint);
      uint256[] memory amount = new uint256[](totalBlueprint);

      for (uint256 i = 0; i < totalBlueprint; i++) {
         ids[i] = i;
         amount[i] = ownerBlueprints[_address][i];
      }

      return (
         ids,
         amount
      );
   }

   function buyBlueprint(uint256 id) public whenNotPaused returns (bool) {
      uint256 value;
      bool disabled;

      (,,,,,,value,disabled) = fcbBlueprint.getBlueprintDetail(id);

      require(!disabled && value > 0, "Blueprint does not exist");

      fcToken.transferFrom(msg.sender, address(this), value);

      ownerBlueprints[msg.sender][id]++;

      return true;
   }

   function reveal(uint256 blueprintId) public whenNotPaused returns (bytes32) {
      require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK");
      require(ownerBlueprints[msg.sender][blueprintId] > 0, "Not enough blueprint");

      ownerBlueprints[msg.sender][blueprintId]--;

      bytes32 requestId = requestRandomness(keyHash, fee);
      requestIdToSender[requestId] = msg.sender;
      requestIdBlueprintId[requestId] = blueprintId;

      return requestId;
   }

   function fulfillRandomness(bytes32 requestId, uint256 randomNumber) internal override {
      address _requester = requestIdToSender[requestId];
      require(_requester != address(0), "Null address not allowed");
      uint256[] memory randomNumbers = expandRandomness(randomNumber, 4);

      uint256 newId        = buildings.length;
      uint256 rarity       = getRarity(randomNumbers[0],requestIdBlueprintId[requestId]);
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

      _safeMint(_requester, newId);

      emit newBuilding(newId, _requester);

      requestIdToSender[requestId] = address(0);
   }

   function revealTest(uint256 blueprintId) public whenNotPaused returns (bytes32) {
      require(ownerBlueprints[msg.sender][blueprintId] > 0, "Not enough blueprint");

      ownerBlueprints[msg.sender][blueprintId]--;

      bytes32 requestId = "asd";
      requestIdToSender[requestId] = msg.sender;
      requestIdBlueprintId[requestId] = blueprintId;

      return requestId;
   }

   function fulfillTest(bytes32 requestId, uint256 randomNumber) public {
      fulfillRandomness(requestId, randomNumber);
   }

   function expandRandomness(uint256 randomNumber, uint256 n) internal pure returns (uint256[] memory) {
      uint256[] memory expandedValues = new uint256[](n);

      for (uint256 i = 0; i < n; i++) {
         expandedValues[i] = uint256(keccak256(abi.encode(randomNumber, i)));
      }

      return expandedValues;
   }

   function getRarity(uint256 randomNumber, uint256 blueprintId) public view returns (uint256) {
      uint256 common;
      uint256 uncommon;
      uint256 rare;
      uint256 epic;
      uint256 legendary;
      (,common,uncommon,rare,epic,legendary,,) = fcbBlueprint.getBlueprintDetail(blueprintId);

      uint256 converted = randomNumber % 100;

      if (converted <= common) {
         return 1;
      } else if (converted <= uncommon) {
         return 2;
      } else if (converted <= rare) {
         return 3;
      } else if (converted <= epic) {
         return 4;
      } else if (converted <= legendary) {
         return 5;
      }

      return 1;
   }

   function getSize(uint256 randomNumber) public pure returns (uint256) {
      uint256 converted = randomNumber % 100;

      return converted < 59 ? 1 : (converted < 94 ? 2 : 3);
   }

   function getBusinessType(uint256 randomNumber) public pure returns (uint256) {
      uint256 converted = randomNumber % 100;

      return converted < 49 ? 1 : (converted < 79 ? 2 : 3);
   }

   function getReputation(uint256 rarity, uint256 businessType, uint256 size, uint256 randomNumber) public pure returns (uint256) {
      uint256 min;
      uint256 max;
      (min, max) = getRangeReputationByRarity(rarity);

      uint256 reputation = randomNumber % (max + 1);
      reputation *= (1 + (businessType / 10) + (size / 10));

      return reputation < min ? min : (reputation > max ? max : reputation);
   }

   function getRangeReputationByRarity(uint256 rarity) public pure returns (uint256, uint256) {
      return (
         (rarity * 50) - 50 + 1,
         rarity * 50
      );
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
      Building memory building = buildings[tokenId];
      return (
         building.rarity,
         building.businessType,
         building.size,
         building.reputation,
         building.level
      );
   }

   function updateAddress(uint256 _type, address _address) public onlyOwner {
      if (_type == 0) {
         fcToken = IERC20(_address);
      } else if (_type == 1) {
         fcbBlueprint = IBuildingBlueprint(_address);
      }
   }

   function withdrawalToken(address _address, address destination, uint256 amount) public onlyOwner {
      IERC20 tokenContract = IERC20(_address);

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