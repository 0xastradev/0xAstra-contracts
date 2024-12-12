import hre, { ethers } from "hardhat";
import { getDeployParameters } from "./utils";

async function main(): Promise<void> {
  const deployParameters = await getDeployParameters();

  const opool = "0xb459C852b5C2aD8121D65a1dbe7342152F798Fe8";
  if (opool) {
    console.log("Verify opool");
    try {
      await hre.run("verify:verify", {
        address: opool,
        constructorArguments: [
          'https://bafybeidepc5qqwt5xtzgrbionxnzv2qpwa5ajgqhgirfkqzefbpy4g6rlu.ipfs.dweb.link/',
          '0xb1AC39A9078056Ae063618Ed9E2F54d04f8196eE',
          '0x92cd0cC31730226417350c297Eec96157F6f7c35'
        ],
      });
    } catch (error) {
      console.error(error);
    }
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
