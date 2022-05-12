const hardhat = require("hardhat");

async function main() {
  const address = "0x003f4CcaDd6E5f05345321115f658BfefAFe9198";

  const provider = new hardhat.ethers.providers.JsonRpcProvider();
  const signer   = await hardhat.ethers.getSigner();

  const addressToken             = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
  const addressBlueprintBuilding = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
  const addressBuilding          = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";

  const abi = [
      "function name() view returns (string)",
      "function symbol() view returns (string)",

      "function balanceOf(address) view returns (uint)",

      "function transfer(address to, uint amount)",

      "function approve(address spender, uint256 amount) returns (bool)",

      "function allowance(address owner, address spender) view returns (uint256)",

      "function ban(address _address)",

      "function unban(address _address)",
      
      "function banned() view returns (bool)",

      "event Transfer(address indexed from, address indexed to, uint amount)"
  ];

  let contractToken = new hardhat.ethers.Contract(addressToken, abi, signer);

  const abiBlueprintBuilding = [
      "function createBlueprint(string name, uint256 common, uint256 uncommon, uint256 rare, uint256 epic, uint256 legendary, uint256 value)",
      "function disableBlueprint(uint256 id) returns (bool)",

      "function getBlueprintDetail(uint256 id) view returns (string, uint256, uint256, uint256, uint256, uint256, uint256, bool)",
      "function getTotalBlueprints() view returns (uint256)",
      "function updateValue(uint256 blueprintId, uint256 value)",
      "function withdrawalToken(address contractAddress, address destination, uint256 amount)",
  ];

  let contractBlueprintBuilding = new hardhat.ethers.Contract(addressBlueprintBuilding, abiBlueprintBuilding, signer);

  const abiBuilding = [
      "function getOwnedBlueprints() view returns (uint256[], uint256[])",
      "function getBlueprintsFromAddress(address _address) view returns (uint256[], uint256[])",

      "function buyBlueprint(uint256 id) returns (bool)",

      "function reveal(uint256 blueprintId) returns (bytes32)",
      "function forTest(bytes32 requestId, uint256 randomNumber)",
      "function getBuildingDetail(uint256 tokenId) view returns (uint256, uint256, uint256, uint256, uint256)",

      "function updateAddress(uint256 _type, address _address)",
      "function withdrawalToken(address contractAddress, address destination, uint256 amount)",
  ];

  let contractBuilding = new hardhat.ethers.Contract(addressBuilding, abiBuilding, signer);

  await contractBlueprintBuilding.createBlueprint("Unique", 43,79,93,98,99,ethers.utils.parseUnits("100",18))

  await contractToken.transfer(address, hardhat.ethers.utils.parseUnits("5000", 18));

  await signer.sendTransaction({
    to: address,
    value: ethers.utils.parseEther("1000")
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
