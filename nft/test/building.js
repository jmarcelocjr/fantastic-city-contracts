const chai = require("chai");
const expect = chai.expect;
chai.use(require("chai-as-promised"));

const { ethers } = require("hardhat");

describe("Building", function () {
  it("Should buy a blueprint", async function () {
    const fcToken    = await ethers.getContractFactory("FCToken");
    const fcContract = await fcToken.deploy();
    await fcContract.deployed();

    const fcbBlueprint         = await ethers.getContractFactory("FantasticCityBuildingBlueprint");
    const fcbBlueprintContract = await fcbBlueprint.deploy();
    await fcContract.deployed();

    const token = await ethers.getContractFactory("FantasticCityBuilding");
    const contract = await token.deploy(fcContract.address, fcbBlueprintContract.address, "0xa555fC018435bef5A13C6c6870a9d4C11DEC329C", "0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06", "0xcaf3c3727e033261d383b315559476f48034c13b18f8cafed4d871abe5049186");
    await contract.deployed();

    fcContract.approve(contract.address, fcContract.totalSupply());

    await fcbBlueprintContract.createBlueprint("common", 43, 78, 93, 94, 99, 15);

    await contract.buyBlueprint(0);
    await contract.buyBlueprint(0);

    [ids, amount] = await contract.getOwnedBlueprints();

    expect(ethers.utils.formatUnits(ids[0], 0)).to.equal('0');
    expect(ethers.utils.formatUnits(amount[0], 0)).to.equal('2');
  });
});
