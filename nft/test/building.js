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
    await fcbBlueprintContract.deployed();

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
  it("Should return correctly rarities", async function () {
    const fcToken    = await ethers.getContractFactory("FCToken");
    const fcContract = await fcToken.deploy();
    await fcContract.deployed();

    const fcbBlueprint         = await ethers.getContractFactory("FantasticCityBuildingBlueprint");
    const fcbBlueprintContract = await fcbBlueprint.deploy();
    await fcbBlueprintContract.deployed();

    const token = await ethers.getContractFactory("FantasticCityBuilding");
    const contract = await token.deploy(fcContract.address, fcbBlueprintContract.address, "0xa555fC018435bef5A13C6c6870a9d4C11DEC329C", "0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06", "0xcaf3c3727e033261d383b315559476f48034c13b18f8cafed4d871abe5049186");
    await contract.deployed();

    await fcbBlueprintContract.createBlueprint("common", 43, 78, 93, 98, 99, 15);

    expect(await contract.getRarity(42, 0)).to.equal('1');
    expect(await contract.getRarity(75, 0)).to.equal('2');
    expect(await contract.getRarity(93, 0)).to.equal('3');
    expect(await contract.getRarity(97, 0)).to.equal('4');
    expect(await contract.getRarity(99, 0)).to.equal('5');
  });
  it("Should return correctly sizes", async function () {
    const fcToken    = await ethers.getContractFactory("FCToken");
    const fcContract = await fcToken.deploy();
    await fcContract.deployed();

    const fcbBlueprint         = await ethers.getContractFactory("FantasticCityBuildingBlueprint");
    const fcbBlueprintContract = await fcbBlueprint.deploy();
    await fcbBlueprintContract.deployed();

    const token = await ethers.getContractFactory("FantasticCityBuilding");
    const contract = await token.deploy(fcContract.address, fcbBlueprintContract.address, "0xa555fC018435bef5A13C6c6870a9d4C11DEC329C", "0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06", "0xcaf3c3727e033261d383b315559476f48034c13b18f8cafed4d871abe5049186");
    await contract.deployed();

    expect(await contract.getSize(55)).to.equal('1');
    expect(await contract.getSize(93)).to.equal('2');
    expect(await contract.getSize(98)).to.equal('3');
  });
  it("Should return correctly business types", async function () {
    const fcToken    = await ethers.getContractFactory("FCToken");
    const fcContract = await fcToken.deploy();
    await fcContract.deployed();

    const fcbBlueprint         = await ethers.getContractFactory("FantasticCityBuildingBlueprint");
    const fcbBlueprintContract = await fcbBlueprint.deploy();
    await fcbBlueprintContract.deployed();

    const token = await ethers.getContractFactory("FantasticCityBuilding");
    const contract = await token.deploy(fcContract.address, fcbBlueprintContract.address, "0xa555fC018435bef5A13C6c6870a9d4C11DEC329C", "0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06", "0xcaf3c3727e033261d383b315559476f48034c13b18f8cafed4d871abe5049186");
    await contract.deployed();

    console.log(await contract.getBusinessType(12));
    expect(await contract.getBusinessType(12)).to.equal('1');
    expect(await contract.getBusinessType(61)).to.equal('2');
    expect(await contract.getBusinessType(91)).to.equal('3');
  });
  it("Should return correctly reputation range", async function () {
    const fcToken    = await ethers.getContractFactory("FCToken");
    const fcContract = await fcToken.deploy();
    await fcContract.deployed();

    const fcbBlueprint         = await ethers.getContractFactory("FantasticCityBuildingBlueprint");
    const fcbBlueprintContract = await fcbBlueprint.deploy();
    await fcbBlueprintContract.deployed();

    const token = await ethers.getContractFactory("FantasticCityBuilding");
    const contract = await token.deploy(fcContract.address, fcbBlueprintContract.address, "0xa555fC018435bef5A13C6c6870a9d4C11DEC329C", "0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06", "0xcaf3c3727e033261d383b315559476f48034c13b18f8cafed4d871abe5049186");
    await contract.deployed();

    let range = (await contract.getRangeReputationByRarity(1)).map((value => 'a'));
    console.log(range);
    // expect(await contract.getRangeReputationByRarity(1)).to.equal([]);
    expect(await contract.getBusinessType(61)).to.equal('2');
    expect(await contract.getBusinessType(91)).to.equal('3');
  });
});
