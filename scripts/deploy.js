const hre = require("hardhat");

async function main() {
  const [signer] = await hre.ethers.getSigners();

  const market_contract = await hre.ethers.deployContract(
    "Market",
    [signer.address, 1],
    {
      signer: signer,
    }
  );

  await market_contract.waitForDeployment();

  const nft_contract = await hre.ethers.deployContract(
    "NFT",
    [market_contract.target, "Codewalk", "CDW"],
    {
      signer: signer,
    }
  );

  await nft_contract.waitForDeployment();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
