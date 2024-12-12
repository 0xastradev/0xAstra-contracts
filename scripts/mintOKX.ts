import { ethers, network } from "hardhat";
import { deployerConfiguration, getDeployParameters } from "./utils";
import { parseEther } from "ethers";

export async function main() {
  const deployer = await deployerConfiguration();
  console.log("deployer: ", await deployer.getAddress());

  const contractName = "OKXSBT";
  const rewardContract = await ethers.getContractAt(contractName, '0x33e5d35d463ad0890c0c38c4063208c1a6eda5a5', deployer);
  const hash = await rewardContract.mintTo('0x91ea0eb3215b0c5b133b5f3382ec9afcf4a075dd', 1, 12)
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
