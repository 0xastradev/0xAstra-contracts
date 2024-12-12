import { ethers, network } from "hardhat";
import { deployerConfiguration, getDeployParameters } from "./utils";
import fs from "fs";

export async function AstraDeployment() {
  const deployer = await deployerConfiguration();
  const contractName = "AstraChargeCard";
  const AstraNFTFactory = await ethers.getContractFactory(contractName);
  const AstraNFTContract = (await AstraNFTFactory.connect(deployer).deploy(
    'https://bafybeidepc5qqwt5xtzgrbionxnzv2qpwa5ajgqhgirfkqzefbpy4g6rlu.ipfs.dweb.link/',
    '0xb1AC39A9078056Ae063618Ed9E2F54d04f8196eE',
    '0x92cd0cC31730226417350c297Eec96157F6f7c35'
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
