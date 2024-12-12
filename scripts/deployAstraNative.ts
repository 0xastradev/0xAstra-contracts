import { ethers, network } from "hardhat";
import { expect } from "chai";
import { deployerConfiguration, getDeployParameters } from "./utils";
import fs from "fs";
import path from "path";

export async function main() {
  const deployer = await deployerConfiguration();
  console.log("deployer: ", await deployer.getAddress());

  const contractName = "AstraRewardsNative";
  const factory = await ethers.getContractFactory(contractName);
  const rewardContract = (await factory.connect(deployer).deploy(
    deployer.getAddress(),
    ["0xEB85F613F3A8a9Ca4F74BB9019bC9cBb44C02C56"]
  )) 

  const deployOut = {
    network: network.name,
    oLottery: await rewardContract.getAddress(),
  };

  const localPath = `scripts/deployOutput_${contractName}_${network.name}.json`;

  fs.writeFileSync(localPath, JSON.stringify(deployOut, null, 2));

  console.log("AstraRewardsNative deployed to: ", await rewardContract.getAddress());
}

main()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(() => {
    // exit the script
    process.exit();
  });
