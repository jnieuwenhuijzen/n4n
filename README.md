# Build your own NFT

Many thanks and credits to [Fireship](https://fireship.io/), based on Fireship's [WEB3 NFT TUTORIAL](https://fireship.io/lessons/web3-solidity-hardhat-react-tutorial/)

## Prepare

Make sure to have the following packages installed:

* [NPM / Node.js](https://nodejs.org/en/download/)
* Browser with [Metamask Extension](https://metamask.io/download/)
* [Git](https://git-scm.com/downloads) If you want to download the prefab art
* Your favourite IDE e.g. [VS Code](https://code.visualstudio.com/)

Also create free accounts at:

* [Pinata](https://pinata.cloud) for uploading content to IPFS
* [Alchemy](https://www.alchemy.com/) for connecting to a public blockchain node

Learn how to connect to a custom network in MetaMask

* [Connecting Hardhat to Metamask](https://www.youtube.com/watch?v=FTDEX3S1eqU) - Check the video and maybe setup a custom network to localhost already. We will install hardhat later on. (and we will use chainId 1337)

## Table of contents

* **Initial Setup**
  * [Generate art](#generate-art)
  * [Upload Art to IPFS](#upload-art-to-ipfs)
  * [Setup Hardhat](#setup-hardhat)
* **Smart Contract**
  * [Base ERC-721 Contract](#base-erc-721-contract)
  * [Ensure URIs are Unique](#ensure-uris-are-unique)
  * [Pay to Mint](#pay-to-mint)
  * [Deploy Contract](#deploy-contract)
* **Web3 Frontend**
  * [Check for Wallet Plugin](#check-for-wallet-plugin)
  * [Get the Wallet Balance](#get-the-wallet-balance)
  * [Loop through Existing NFTs](#loop-through-existing-nfts)
  * [Mint a new Token](#mint-a-new-token)
* **Deploy**
  * [Setup connection to Mumbai](#setup-connection-to-mumbai)
  * [Deploy to Mumbai network](#deploy-to-mumbai-network)

<br><br><br><br><br><br>

```console
  _____       _ _   _       _   __      _
  \_   \_ __ (_) |_(_) __ _| | / _\ ___| |_ _   _ _ __
   / /\/ '_ \| | __| |/ _` | | \ \ / _ \ __| | | | '_ \
/\/ /_ | | | | | |_| | (_| | | _\ \  __/ |_| |_| | |_) |
\____/ |_| |_|_|\__|_|\__,_|_| \__/\___|\__|\__,_| .__/
                                                 |_|
```

## Generate Art

Create your own art! Art can be anything. You can e.g. use the really cool examples from Fireship, or, in this case I just used some pictures of my cat who has a tendency to lie in awkward positions. Pictures can be in the form of PNG, GIF, JPEG, etc.

With each picture a json-file is accompanied that contains metadata for that picture. We use a [standard](https://docs.opensea.io/docs/metadata-standards) that is supported by [OpenSea](https://opensea.io/).

In the project directory named `n4n`, place the pictures in the directory `img` and the metadata (json) files in the directory `json` (or clone this project to use the coolcats picture samples)

## Upload Art to IPFS

Upload the pictures using [Pinata](https://pinata.cloud/). Use the `Folder` option under `Files` and upload the complete `img` folder. Copy the CID and use it to adjust all json metadata files so they will use the CID location of your just uploaded images.

Then also upload the metadata files in the `json` folder. Take note of this new CID, we will use it later on.

## Setup Hardhat

*(Below steps can be skipped if you choose to clone this project and install dependencies using `npm install`)*

First setup a react project (choose `react` in the upcoming menu):

```console
npm init vite myapp
```

Install hardhat in the directory `myapp`, select `Create a basic sample project` in the upcoming menu:

```console
cd myapp

npx hardhat
npm install --save-dev @nomiclabs/hardhat-waffle ethereum-waffle chai @nomiclabs/hardhat-ethers ethers
npm install --save-dev @openzeppelin/contracts

npm run dev
```

As a final preparation, adjust the module.exports in the `hardhat.config.js` to the following:

```js
module.exports = {
  solidity: "0.8.4",
  paths: {
    artifacts: './src/artifacts',
  },
  networks: {
    hardhat: {
      chainId: 1337
    },
  }
};
```

<br><br><br><br><br><br>

```console
 __                      _       ___            _                  _
/ _\_ __ ___   __ _ _ __| |_    / __\___  _ __ | |_ _ __ __ _  ___| |_
\ \| '_ ` _ \ / _` | '__| __|  / /  / _ \| '_ \| __| '__/ _` |/ __| __|
_\ \ | | | | | (_| | |  | |_  / /__| (_) | | | | |_| | | (_| | (__| |_
\__/_| |_| |_|\__,_|_|   \__| \____/\___/|_| |_|\__|_|  \__,_|\___|\__|

```

## Base ERC-721 Contract

* Use [OpenZeppelin wizard](https://docs.openzeppelin.com/contracts/4.x/wizard) to create a mintable, auto-increment-ids, with URI Storage ERC721
* Copy the contract to contracts directory, name it `CoolCats.sol`

## Ensure URIs are Unique

First, create a mapping to ensure each token has a unique URI. Second, define a public function that can determine if a URI is already owned.

```solidity
contract CoolCats is ERC721, ERC721URIStorage, Ownable {

    mapping(string => bool) existingURIs;

  // ...

    function isContentOwned(string memory uri) public view returns (bool) {
        return existingURIs[uri] == true;
    }
}
```

## Pay to Mint

Let’s add an additional method to the contract that handles the minting of a new token. It is a payable method, which means Ether (or other tokens like MATIC) can be sent from the end-user to the contract.

The method uses require to validate that (1) the URI is not already taken, and (2) the minimum amount of Ether has been sent. When the user calls this method, their wallet will prompt them for permission to transfer funds and execute the transation. In return, they will be given a new token linked to the metadata URI on IPFS.

```solidity
contract CoolCats is ERC721, ERC721URIStorage, Ownable {

    // ...

    function payToMint(address to, string memory uri) public payable {
        require(!existingURIs[uri], 'NFT already minted!');
        require (msg.value >= 0.05 ether, 'Need to pay up!');
        existingURIs[uri] = true;

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _mint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

}
```

Also add the `count` function, we need it later on (seems to be missing in the fireship tutorial)

```solidity
contract CoolCats is ERC721, ERC721URIStorage, Ownable {

    function count() public view returns (uint256) {
      return _tokenIdCounter.current();
    }
}
```

## Deploy Contract

Deploy the contract: First update the `scripts/sample-script.js` with your contract details.

```js
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
```

Use hardhat to run a blockchain network on localhost, then compile and deploy it from the terminal.

```console
# terminal 1
npx hardhat node

# terminal 2
npx hardhat compile
npx hardhat run scripts/sample-script.js --network localhost
```

<br><br><br><br><br><br>

```console
 __    __     _    _____     ___                _                 _
/ / /\ \ \___| |__|___ /    / __\ __ ___  _ __ | |_ ___ _ __   __| |
\ \/  \/ / _ \ '_ \ |_ \   / _\| '__/ _ \| '_ \| __/ _ \ '_ \ / _` |
 \  /\  /  __/ |_) |__) | / /  | | | (_) | | | | ||  __/ | | | (_| |
  \/  \/ \___|_.__/____/  \/   |_|  \___/|_| |_|\__\___|_| |_|\__,_|

```

## Check for Wallet Plugin

Create a component `Install.jsx` in the directory `src/components/` that will check for the MetaMask plugin:

```js
const Install = () => {
    return (
      <div>
        <h3>Follow the link to install 👇🏼</h3>
        <a href="https://metamask.io/download.html">Meta Mask</a>
      </div>
    );
  };

export default Install;
```

If the plugin is installed then render the Home screen. Adjust `App.jsx` as follows:

```js
import Install from './components/Install';
import Home from './components/Home';

function App() {

  if (window.ethereum) {
    return <Home />;
  } else {
    return <Install />
  }
}

export default App;
```

## Get the Wallet Balance

Create a component `WalletBalance.jsx` in the directory `src/components/` that will check for the balance of the current account in MetaMask:

```js
import { useState } from 'react';
import { ethers } from 'ethers';

function WalletBalance() {

  const [balance, setBalance] = useState();

  const getBalance = async () => {
    const [account] = await window.ethereum.request({ method: 'eth_requestAccounts' });
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const balance = await provider.getBalance(account);
    setBalance(ethers.utils.formatEther(balance));
  };

  return (
    <div className="card">
      <div className="card-body">
        <h5 className="card-title">Your Balance: {balance}</h5>
        <button className="btn btn-success" onClick={() => getBalance()}>Show My Balance</button>
      </div>
    </div>
  );
};

export default WalletBalance;
```

Test the Wallet Balance functionality by adding some code to `Home.jsx` in the directory `src/components/`:

```js
import WalletBalance from './WalletBalance';

function Home() {
  return (
    <WalletBalance />
  );
}

export default Home;
```

## Loop through Existing NFTs

In the home screen, we use ethers.js to make a reference to the deployed contract. We request the total number of minted tokens, then create a loop to render a child component for each one. Replace the content of `Home.jsx` with the following (do not forget to replace the parameter `YOUR_DEPLOYED_CONTRACT_ADDRESS` with your deployment address):

```js
import WalletBalance from './WalletBalance';
import { useEffect, useState } from 'react';

import { ethers } from 'ethers';
import CoolCats from '../artifacts/contracts/CoolCats.sol/CoolCats.json';

const contractAddress = 'YOUR_DEPLOYED_CONTRACT_ADDRESS';

const provider = new ethers.providers.Web3Provider(window.ethereum);

// get the end user
const signer = provider.getSigner();

// get the smart contract
const contract = new ethers.Contract(contractAddress, CoolCats.abi, signer);


function Home() {

  const [totalMinted, setTotalMinted] = useState(0);
  useEffect(() => {
    getCount();
  }, []);

  const getCount = async () => {
    const count = await contract.count();
    console.log(parseInt(count));
    setTotalMinted(parseInt(count));
  };

 return (
    <div>
      <WalletBalance />

      <h1>Cool Cats NFT Collection</h1>
      <div className="container">
        <div className="row">
          {Array(totalMinted + 1)
            .fill(0)
            .map((_, i) => (
              <div key={i} className="col-sm">
                <NFTImage tokenId={i} getCount={getCount} />
              </div>
            ))}
        </div>
      </div>
    </div>
  );
}

function NFTImage() {
  return (<div>placeholder</div>);
}

export default Home;
```

## Mint a new Token

Next also replace the placeholder function `NFTImage()` in `Home.jsx` with the following function. Do not forget to replace the parameters `PINATA_CONTENT_ID` with the corresponding CID's you got from Pinata:

```js
function NFTImage({ tokenId, getCount }) {
  const jsonContentId = 'PINATA_CONTENT_ID';
  const imgContentId = 'PINATA_CONTENT_ID';
  const metadataURI = `${jsonContentId}/${tokenId}.json`;
  const partialMetadataURI = `${tokenId}.json`;
  const imageURI = `https://gateway.pinata.cloud/ipfs/${imgContentId}/${tokenId}.jpeg`;

  const [isMinted, setIsMinted] = useState(false);
  useEffect(() => {
    getMintedStatus();
  }, [isMinted]);

  const getMintedStatus = async () => {
    const result = await contract.isContentOwned(partialMetadataURI);
    console.log(result)
    setIsMinted(result);
  };

  const mintToken = async () => {
    const connection = contract.connect(signer);
    const addr = connection.address;
    const result = await contract.payToMint(addr, partialMetadataURI, {
      value: ethers.utils.parseEther('0.05'),
    });

    await result.wait();
    getMintedStatus();
    getCount();
  };

  async function getURI() {
    const uri = await contract.tokenURI(tokenId);
    alert(uri);
  }

  return (
    <div className="card" style={{ width: '18rem'}}>
      <img className="card-img-top" src={isMinted ? imageURI : './placeholder.jpeg'}></img>
      <div className="card-body">
        <h5 className="card-title">ID #{tokenId}</h5>
        {!isMinted ? (
          <button className="btn btn-primary" onClick={mintToken}>
            Mint
          </button>
        ) : (
          <button className="btn btn-secondary" onClick={getURI}>
            Taken! Show URI
          </button>
        )}
      </div>
    </div>
  );
}
```

<br><br><br><br><br><br>

```console
    ___           _
   /   \___ _ __ | | ___  _   _
  / /\ / _ \ '_ \| |/ _ \| | | |
 / /_//  __/ |_) | | (_) | |_| |
/___,' \___| .__/|_|\___/ \__, |
           |_|            |___/
```

## Setup connection to Mumbai

Use [Alchemy](https://www.alchemy.com/) to get a personal Alchemy API key for a connection to a Mumbai node (Polygons test network). Setup a new network in MetaMask with the following fields:

|   |   |
|---|---|
|Network Name|Mumbai|
|New RPC URL|[https://polygon-mumbai.g.alchemy.com/v2/ALCHEMY_API_KEY](https://polygon-mumbai.g.alchemy.com/v2/ALCHEMY_API_KEY)|
|Chain ID|80001|
|Currency Symbol|MATIC|
|Block Explorer URL|[https://mumbai.polygonscan.com](https://mumbai.polygonscan.com)|

Uncomment the Mumbai section in `hardhat.config.js` and fill in your ALCHEMY_API_KEY and MUMBAI_PRIVATE_KEY

```js
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
    mumbai: {
      url: `https://polygon-mumbai.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      chainId: 80001,
      accounts: [MUMBAI_PRIVATE_KEY]
    }
  }
};
```

## Deploy to Mumbai network

If you do not have any test MATIC you can get some at this [faucet](https://faucet.polygon.technology/)

You can now deploy the smart contract on Mumbai network as follows:

```console
npx hardhat run scripts/sample-script.js --network mumbai
```

Finally change the smart contract address in the react component `Home.jsx` to the address at Mumbai:

```js
const contract address = '0x..(the new smart contract address)';
```

As a bonus, check your NFTs on [https://testnets.opensea.io/](https://testnets.opensea.io/). Search for your NFTs using the same contract address and make for some cosmetic changes. Happy days!
