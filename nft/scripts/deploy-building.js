// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const Building = await hre.ethers.getContractFactory("FantasticCityBuilding");
  const building = await Building.deploy("0x55E4E57C11f571827547fa1ADeE75dC204673E96", "0xa555fC018435bef5A13C6c6870a9d4C11DEC329C", "0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06", "0xcaf3c3727e033261d383b315559476f48034c13b18f8cafed4d871abe5049186");

  await building.deployed();

  console.log("Building deployed to:", building.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
