const hre = require("hardhat");

async function main() {

  const CoolCats = await hre.ethers.getContractFactory("CoolCats");
  const coolCats = await CoolCats.deploy();

  await coolCats.deployed();

  console.log("My NFT deployed to:", coolCats.address);
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
