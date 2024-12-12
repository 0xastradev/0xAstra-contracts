import { expect } from "chai";
import { ethers } from "hardhat";

describe("AstraIntelCollect", function () {
  let AstraIntelCollect;
  let astraIntelCollect;

  it("should correctly decode the address from the message", async function () {
    const testAddress = "0x0bB902fC9e168343a19d622E79cE033452e64Dd8";

    // Encode the address as per the given format
    const encodedMessage =
      "0x00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000014e1849e61296626cd8e3717082f1b940e2a7dbc52000000000000000000000000";

    // Create a mock function to replace _collect
    const mockCollect = await ethers.getContractFactory(
      "MockAstraIntelCollect"
    );
    const mockContract = await mockCollect.deploy();
    await mockContract.deploymentTransaction()

    // Call _receiveMessage with the encoded message
    const collectedAddress = await mockContract.testReceiveMessage(
      encodedMessage
    );
    console.log(collectedAddress);

    expect(collectedAddress).to.equal(testAddress.toLowerCase());
  });
});
