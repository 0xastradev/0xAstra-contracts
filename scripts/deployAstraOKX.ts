import { ethers, network } from "hardhat";
import { expect } from "chai";
import { deployerConfiguration, getDeployParameters } from "./utils";
import fs from "fs";
import path from "path";

export async function main() {
  const deployer = await deployerConfiguration();
  console.log("deployer: ", await deployer.getAddress());

  const contractName = "OKXSBT";
  const LotteryFactory = await ethers.getContractFactory(contractName);

  const Lottery = (await LotteryFactory.connect(deployer).deploy(
    "0x0a967071c519366e8f86bdfbd72e238d121084edb4f8999e2608870d3723b3fb",
    "https://0xastra.xyz/sbt.json",
  ));

  const deployOut = {
    network: network.name,
    oLottery: await Lottery.getAddress(),
  };
  const localPath = `scripts/deployOutput_${contractName}_${network.name}.json`;

  fs.writeFileSync(localPath, JSON.stringify(deployOut, null, 2));

  console.log("deployed to: ", await Lottery.getAddress());
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
