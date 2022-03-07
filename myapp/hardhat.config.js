require("@nomiclabs/hardhat-waffle");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// Go to https://www.alchemyapi.io, sign up, create
// a new App in its dashboard, and replace "" with its key
const ALCHEMY_API_KEY = "";

// Replace this private key with your Mumbai account private key
// To export your private key from Metamask, open Metamask and
// go to Account Details > Export Private Key
// Be aware of NEVER putting real Ether into testing accounts
const MUMBAI_PRIVATE_KEY = "";
// address: 0x

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.4",
  paths: {
    artifacts: './src/artifacts',
  },
  networks: {
    hardhat: {
      chainId: 1337
    },
    // mumbai: {
    //   url: `https://polygon-mumbai.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
    //   chainId: 80001,
    //   accounts: [MUMBAI_PRIVATE_KEY]
    // }
  }
};
