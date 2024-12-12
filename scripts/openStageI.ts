import { ethers, network } from "hardhat";
import { expect } from "chai";
import { deployerConfiguration, getDeployParameters } from "./utils";
import fs from "fs";
import path from "path";

export async function openStageI() {
  let currentProvider = ethers.provider;
  const deployer = new ethers.Wallet(
    process.env.NFT_PRIVATE_KEY as string,
    currentProvider
  );
  console.log("deployer: ", await deployer.getAddress());

  const contractName = "AstraGenesisNFT";
  const nftContract = await ethers.getContractAt(contractName, '0x1Ff4bf1E4EfE865c3F0e532ac0B2FE6876AA978a', deployer);
  const hash = await nftContract["setMintStatus"](1)
  console.log(hash, 'hash')
}

openStageI()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(() => {
    // exit the script
    process.exit();
  });
