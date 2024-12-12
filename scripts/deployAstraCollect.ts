import { ethers, network } from "hardhat";
import { deployerConfiguration, getDeployParameters } from "./utils";
import fs from "fs";

export async function AstraDeployment() {
  const deployer = await deployerConfiguration();
  const contractName = "AstraIntelCollect";
  console.log("deploy", deployer)
  const AstraIntelCollectFactory = await ethers.getContractFactory(contractName);
  const AstraIntelCollect = (await AstraIntelCollectFactory.connect(deployer).deploy(
    '0x523D8B6893D2D0Ce2B48E7964432ce19A2C641F2',
    28518,
    '0x2B90E8b07F06E801580e32eBa32d2f6ea891f2a4'
  ))

  const deployOut = {
    network: network.name,
    Astra: await AstraIntelCollect.getAddress(),
  };
  //@ts-ignore
  console.log("deployOut", deployOut , "hash", AstraIntelCollect.deploymentTransaction().hash)
  const localPath = `scripts/deployOutput_${contractName}_${network.name}.json`;

  fs.writeFileSync(localPath, JSON.stringify(deployOut, null, 2));

  console.log("astra collect deployed to: ", await AstraIntelCollect.getAddress());
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
