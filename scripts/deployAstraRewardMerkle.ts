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
  const Lottery = (await LotteryFactory.deploy(
      deployer.getAddress(),"0x524d754e8428a25a690a098e9ef28049381fe0df4fdaea91d433d33bf017ea01",
    "0x95cef13441be50d20ca4558cc0a27b601ac544e5"
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
