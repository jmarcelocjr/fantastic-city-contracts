const chai = require("chai");
const expect = chai.expect;
chai.use(require("chai-as-promised"));

const { ethers } = require("hardhat");

describe("Building Blueprint", function () {
  it("Should create a blueprint", async function () {
    const token = await ethers.getContractFactory("FantasticCityBuildingBlueprint");
    const contract = await token.deploy();
    await contract.deployed();

    const id = await contract.createBlueprint("common", 43, 78, 93, 94, 99, 15);

    expect((await contract.getBlueprintDetail(0))[0]).to.equal("common");
  });
  it("Should disable a blueprint", async function () {
    const token = await ethers.getContractFactory("FantasticCityBuildingBlueprint");
    const contract = await token.deploy();
    await contract.deployed();

    await contract.createBlueprint("common", 43, 78, 93, 94, 99, 15);
    const response = await contract.disableBlueprint(0);

    expect(response).to.be.an("object");
    expect(response.confirmations).to.equal(1);
  });
  it("Should update a blueprint value", async function () {
    const token = await ethers.getContractFactory("FantasticCityBuildingBlueprint");
    const contract = await token.deploy();
    await contract.deployed();

    await contract.createBlueprint("common", 43, 78, 93, 94, 99, 15);

    await contract.updateValue(0, 18);

    expect((await contract.getBlueprintDetail(0))[6]).to.equal(18);
  });
  it("Should return a total of 2 blueprints", async function () {
    const token = await ethers.getContractFactory("FantasticCityBuildingBlueprint");
    const contract = await token.deploy();
    await contract.deployed();

    await contract.createBlueprint("common", 43, 78, 93, 94, 99, 15);
    await contract.createBlueprint("legendary", 0, 0, 0, 0, 99, 9999);

    expect(await contract.getTotalBlueprints()).to.equal(2);
  });
});
