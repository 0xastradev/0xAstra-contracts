import { ethers, network } from "hardhat";
import { deployerConfiguration, getDeployParameters } from "./utils";
import fs from "fs";

export async function AstraDeployment() {
  const deployer = await deployerConfiguration();
  const contractName = "AstraGenesisNFTTest";
  const AstraNFTFactory = await ethers.getContractFactory(contractName);
  const AstraNFTContract = (await AstraNFTFactory.connect(deployer).deploy(
    'ASTRA GENESIS NFT',
    'ASTRA GENESIS NFT',
    '0xBdc4ec2eB969076B56a9666Cb91361ac7BB018d7',
    'https://bafybeicfduqocuogiak7g6aye3i7blvbim5jlkx6zjmnspd7fbvrgwhpfe.ipfs.dweb.link/',
    800,
    '0x4ea1eade3f387ec727e57108e0beeb2469f4ebf7159bfa2d972f0cc9df3d5491',
    '0x2a928a54d7ed1a81c31c5b8f82d0a4515febade6c0e87680812f9411a8911808',
  ))

  const deployOut = {
    network: network.name,
    Astra: await AstraNFTContract.getAddress(),

  };

  const localPath = `scripts/deployOutput_${contractName}_${network.name}.json`;

  fs.writeFileSync(localPath, JSON.stringify(deployOut, null, 2));

  console.log("astra nft deployed to: ", await AstraNFTContract.getAddress());
}

AstraDeployment()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(() => {
    // exit the script
    process.exit();
  });
