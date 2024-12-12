import hre, { ethers } from "hardhat";
import { getDeployParameters } from "./utils";

async function main(): Promise<void> {
  const deployParameters = await getDeployParameters();

  const opool = "0xed8D056E0737bB5e1daB2128F004d89103aaf34c";
  if (opool) {
    console.log("Verify bera");
    try {
      await hre.run("verify:verify", {
        address: opool,
        constructorArguments: [
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
