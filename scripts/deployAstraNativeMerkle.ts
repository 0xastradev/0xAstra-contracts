import { ethers, network } from "hardhat";
import { expect } from "chai";
import { deployerConfiguration, getDeployParameters } from "./utils";
import fs from "fs";
import path from "path";

export async function main() {
  const deployer = await deployerConfiguration();
  console.log("deployer: ", await deployer.getAddress());

  const contractName = "AstraRewardsMerkle";
  const LotteryFactory = await ethers.getContractFactory(contractName);

  const Lottery = (await LotteryFactory.connect(deployer).deploy(
    deployer.getAddress(),"0xc5a7afb28acdb9cd85a99d8f40806ea9696364ab31cf2a4552e8c13bb677c9dc",
    "0x0e7779e698052f8fe56c415c3818fcf89de9ac6d"
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
