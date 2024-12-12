import { ethers, network } from "hardhat";
import { expect } from "chai";
import { deployerConfiguration, getDeployParameters } from "./utils";
import fs from "fs";
import path from "path";

export async function changeNFTUrl() {
  const currentProvider = ethers.provider;
  if(!process.env.NFT_PRIVATE_KEY) {
    throw new Error("NFT_PRIVATE_KEY is not set");
  }
  const deployer = new ethers.Wallet(
    process.env.NFT_PRIVATE_KEY,
    currentProvider
  ); 
  console.log("deployer: ", await deployer.getAddress());

  const contractName = "AstraGenesisNFT";
  const nftContract = await ethers.getContractAt(contractName, '0x1ff4bf1e4efe865c3f0e532ac0b2fe6876aa978a', deployer);
  const res = await nftContract.setTokenURI('https://0xastra.oss-us-west-1.aliyuncs.com/all_json/')

}

changeNFTUrl()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(() => {
    // exit the script
    process.exit();
  });
