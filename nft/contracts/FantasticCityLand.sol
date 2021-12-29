// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FantasticCityLand is ERC721, ERC721Enumerable, VRFConsumerBase, Ownable {

   IERC20 public fcToken;
   address internal linkToken;
   bytes32 internal keyHash;
   uint256 public fee;
   uint256 public currentValue;

   struct Land {
      uint256 rarity;
      uint256 slots;
      uint256 level;
   }

   Land[] public lands;

   mapping(bytes32 => address) public requestIdToSender;

   event newLand(bytes32 indexed requestId);

   constructor(address _fcToken, address _vrfCoordinator, address _linkToken, bytes32 _keyhash) 
      VRFConsumerBase(_vrfCoordinator, _linkToken)
      ERC721("FantasticCityLand", "FCL")
   {
      fcToken = IERC20(_fcToken);
      linkToken = _linkToken;
      keyHash = _keyhash;
      fee = 0.1 * 10 ** 18;
   }

   function generate() public returns (bytes32)
   {
      require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");

      fcToken.transferFrom(msg.sender, address(this), currentValue);

      bytes32 requestId = requestRandomness(keyHash, fee);
      requestIdToSender[requestId] = msg.sender;

      emit newLand(requestId);

      return requestId;
   }

   function fulfillRandomness(bytes32 requestId, uint256 randomNumber) internal override {
      uint256[] memory randomNumbers = expandRandomness(randomNumber, 2);

      uint256 newId  = lands.length;
      uint256 rarity = getRarity(randomNumbers[0]);
      uint256 slots  = randomNumbers[1] % 10;

      lands.push(
         Land(
            rarity,
            slots,
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

   function getRarity(uint256 randomNumber) internal returns (uint256) {
      uint256 converted = randomNumber % 100;

      if (converted == 99) {
         return 5;
      } else if (converted >= 94) {
         return 4;
      } else if (converted >= 79) {
         return 3;
      } else if (converted >= 44) {
         return 2;
      }

      return 1;
   }

   function getLandDetails(uint256 tokenId) public view 
      returns (
         uint256,
         uint256,
         uint256
      )
   {
      return (
         lands[tokenId].rarity,
         lands[tokenId].slots,
         lands[tokenId].level
      );
   }

   function updateValue(uint256 value) public onlyOwner {
      currentValue = value;
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