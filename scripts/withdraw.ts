import { ethers, network } from "hardhat";
import { expect } from "chai";
import { deployerConfiguration, getDeployParameters } from "./utils";
import fs from "fs";
import path from "path";
import { parseEther } from "ethers";

export async function main() {
  const deployer = await deployerConfiguration();
  console.log("deployer: ", await deployer.getAddress());

  const contractName = "AstraRewardsNativeMerkle";
  const rewardContract = await ethers.getContractAt(contractName, '0x48873254fe2b05d6f0bC765c9F01275803946fD0', deployer);
  const hash = await rewardContract["withdraw(uint256)"](parseEther("205"))
  console.log(hash, 'hash')
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
