//deploy TokenQuery
import { ethers, network } from "hardhat";
import { expect } from "chai";
import { deployerConfiguration, getDeployParameters } from "./utils";
import fs from "fs";
import path from "path";

export async function deployTokenQuery() {
  const deployer = await deployerConfiguration();
  console.log("deployer: ", await deployer.getAddress());

  const contractName = "TokenQuery";
  const factory = await ethers.getContractFactory(contractName);
  const tokenQueryContract = (await factory.connect(deployer).deploy()) 

  const deployOut = {
    network: network.name,
    tokenQuery: await tokenQueryContract.getAddress(),
  };

  const localPath = `scripts/deployOutput_${contractName}_${network.name}.json`;

  fs.writeFileSync(localPath, JSON.stringify(deployOut, null, 2));

  console.log("TokenQuery deployed to: ", await tokenQueryContract.getAddress());
}

deployTokenQuery()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(() => {
    // exit the script
    process.exit();
  });