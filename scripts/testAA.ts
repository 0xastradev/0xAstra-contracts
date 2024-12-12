const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("AstraIntelCollect", function () {
  let astraIntelCollect;
  let owner;

  beforeEach(async function () {
    [owner] = await ethers.getSigners();

    const AstraIntelCollect = await ethers.getContractFactory("AstraIntelCollect");
    astraIntelCollect = await AstraIntelCollect.deploy();
    await astraIntelCollect.deployed();
  });

  it("should correctly decode the address from the message", async function () {
    const testAddress = "0x0bB902fC9e168343a19d622E79cE033452e64Dd8";
    
    // Encode the address as per the given format
    const encodedMessage = ethers.utils.defaultAbiCoder.encode(
      ["bytes"],
      [ethers.utils.defaultAbiCoder.encode(["address"], [testAddress])]
    );

    // Create a mock function to replace _collect
    const mockCollect = await ethers.getContractFactory("MockAstraIntelCollect");
    const mockContract = await mockCollect.deploy();
    await mockContract.deployed();

    // Call _receiveMessage with the encoded message
    await mockContract.testReceiveMessage(
      1, // srcChainId (assuming WHITE_LIST_CHAIN_ID is 1)
      ethers.constants.AddressZero, // srcContract (assuming WHITE_LIST_ADDRESS is address(0))
      encodedMessage
    );

    // Get the collected address from the mock contract
    const collectedAddress = await mockContract.getCollectedAddress();

    // Check if the collected address matches the test address
    expect(collectedAddress.toLowerCase()).to.equal(testAddress.toLowerCase());
  });
});