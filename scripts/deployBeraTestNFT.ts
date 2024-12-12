import { ethers, network } from "hardhat";
import { getDeployParameters } from "./utils";
import fs from "fs";

export async function BeraTestNFTDeployment() {
  const contractName = "BeraTestNFT";
  const BeraTestNFTFactory = await ethers.getContractFactory(contractName);

  const TestBeraERC20Factory = await ethers.getContractFactory("TestBeraERC20");
  const TestBeraERC20Contract = await TestBeraERC20Factory.deploy();
  console.log("test bera erc20 deployed to: ", await TestBeraERC20Contract.getAddress());

  // 移除 connect(deployer)，让 Truffle Dashboard 处理签名
  const BeraTestNFTContract = await BeraTestNFTFactory.deploy();

  const deployOut = {
    network: network.name,
    BeraTestNFT: await BeraTestNFTContract.getAddress(),
  };

  const localPath = `scripts/deployOutput_${contractName}_${network.name}.json`;

  fs.writeFileSync(localPath, JSON.stringify(deployOut, null, 2));

  console.log("bera test nft deployed to: ", await BeraTestNFTContract.getAddress());
}

BeraTestNFTDeployment()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(() => {
    // exit the script
    process.exit();
  });
