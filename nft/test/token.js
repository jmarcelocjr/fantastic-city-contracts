const chai = require("chai");
const expect = chai.expect;
chai.use(require("chai-as-promised"));

const { ethers } = require("hardhat");

describe("Token", function () {
  it("Should transfer 2 token to another wallet", async function () {
    const token = await ethers.getContractFactory("FCToken");
    const contract = await token.deploy();
    await contract.deployed();

    await contract.transfer("0x70997970c51812dc3a010c7d01b50e0d17dc79c8", 2);
    expect(await contract.balanceOf("0x70997970c51812dc3a010c7d01b50e0d17dc79c8")).to.equal(2);
  });

  it("Should return that the wallet is not banned", async function () {
    const token = await ethers.getContractFactory("FCToken");
    const contract = await token.deploy();
    await contract.deployed();

    expect(await contract.banned()).to.equal(false);
  });

  it("Should ban a wallet", async function () {
    const token = await ethers.getContractFactory("FCToken");
    const contract = await token.deploy();
    await contract.deployed();

    await contract.ban(token.signer.getAddress());

    expect(await contract.banned()).to.equal(true);
  });

  it("Should prevent a tranfer from a banned wallet", async function () {
    const token = await ethers.getContractFactory("FCToken");
    const contract = await token.deploy();
    await contract.deployed();

    await contract.ban(token.signer.getAddress());

    await expect(
      contract.transfer("0x70997970c51812dc3a010c7d01b50e0d17dc79c8", 2)
    ).to.eventually.be.rejectedWith(Error);
  });

  it("Should pause a contract", async function () {
    const token = await ethers.getContractFactory("FCToken");
    const contract = await token.deploy();
    await contract.deployed();

    await contract.pause();

    expect(await contract.paused()).to.equal(true);
  });

  it("Should unpause a contract", async function () {
    const token = await ethers.getContractFactory("FCToken");
    const contract = await token.deploy();
    await contract.deployed();

    await contract.pause();

    await contract.unpause();

    expect(await contract.paused()).to.equal(false);
  });

  it("Should not transfer when paused", async function () {
    const token = await ethers.getContractFactory("FCToken");
    const contract = await token.deploy();
    await contract.deployed();

    await contract.pause();

    await expect(
      contract.transfer("0x70997970c51812dc3a010c7d01b50e0d17dc79c8", 2)
    ).to.eventually.be.rejectedWith(Error);
  });
});
