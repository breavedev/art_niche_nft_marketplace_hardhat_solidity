# Art Collectibles Marketplace

An NFT Marketplace for trading Art Collectibles built with Hardhat and Solidity
It comes with a NFT ERC721 contract generated by [OpenZeppelin Wizard](https://wizard.openzeppelin.com/), a test for that contract, and a script that deploys that contract.

NFTs and digital collectibles are growing popular as the web3 space continues to make significant advancements in the blockchain arena. The enormous popularity of NFTs like Cryptokitties and Bored APE pushed investors to purchase ERC721-compatible digital collectibles.

Tools like the OpenZeppelin Wizard that offers developers click and write functionalities to create composable and secure smart contracts in no time, used with Web3 developer tools like Alchemy, make the experience of writing a deploying code on the blockchain easy, fast, and reliable like never before

<p align="center">
  <img src="https://img.shields.io/badge/Solidity-2E8B57?style=for-the-badge&logo=solidity&logoColor=white" />
  <img src="https://img.shields.io/badge/Alchemy-039BE5?style=for-the-badge&logo=alchemy&logoColor=white" />
  <img src="https://img.shields.io/badge/Remix IDE-3e5f8a?style=for-the-badge&logo=remix&logoColor=white" />
  <img src="https://img.shields.io/badge/Hardhat-E6522C?style=for-the-badge&logo=hardhat&logoColor=white" />
  <img src="https://img.shields.io/badge/Ethereum-3C3C3D?style=for-the-badge&logo=Ethereum&logoColor=white" />
  <img src="https://img.shields.io/badge/Smart%20Contracts-8B0000?style=for-the-badge&logo=Ethereum&logoColor=white" />
</p>

## UML Design Diagram

Complete UML diagram of decentralized application design.

<img width="auto" src="./doc/art_collectibles_marketplace_diagram.svg" />

## Configuring the project

The first step is to clone the repository and execute the following command to install all the required modules

```
npm install
```

After that it will be necessary to create an account in Alchemy, infura or another similar service in order to configure the network on which the Dapp will be deployed.

In my case, I have created a project in Alchemy and I have created a `secret.json` file to configure the deployment over the Mumbai testnet as you can see in the `hardhat.config.ts` file of the project:

```
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
const secret = require('./.secret.json');

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
      },
    },
  },
  networks: {
    hardhat: {},
    ganache: {
      url: "http://127.0.0.1:7545",
      allowUnlimitedContractSize: true,
      gas: 2100000,
      gasPrice: 8000000000
    },
    mumbai: {
      url: `https://polygon-mumbai.g.alchemy.com/v2/${secret.projectId}`,
      accounts: [secret.accountPrivateKey]
    }
  }
};

export default config;
```

## Running the test suite

The project has a set of tests to validate the correct behaviour of the contracts and the interaction between them.
You can run the following command to launch the test suite on the local EVM:

```
npx hardhat test
```
<img width="auto" src="./doc/suite_test.PNG" />

You can also use ganache to carry out the tests, for this it is only necessary to use the network option

```
npx hardhat --network ganache test
```
<img width="auto" src="./doc/suite_test_ganache.PNG" />

## Deploying contracts

You can target any network from your Hardhat config using:

```
npx hardhat run --network <network-name> scripts/deploy.ts
```

The project has been deployed on the Mumbai testnet, the addresses of the contracts are as follows:

```
Faucet contract deployed to 0x6dF5B51DA5587611eAFd0AA7727f0a8CAf9B6B7C
ArtMarketplace contract deployed to 0x8fdaf1C8797806C55F451cDA62518A1ADCd81db2
ArtCollectible contract deployed to 0x3DC120791f02882600D15410cbaF44B0AafD0621
```
You can use the Remix IDE to interact with the contracts at those addresses:

<img width="auto" src="./doc/remix_ide.PNG" />

## Visitors Count

<img width="auto" src="https://profile-counter.glitch.me/art_collectibles_marketplace/count.svg" />

## Please Share & Star the repository to keep me motivated.
  <a href = "https://github.com/sergio11/art_collectibles_marketplace/stargazers">
     <img src = "https://img.shields.io/github/stars/sergio11/art_collectibles_marketplace" />
  </a>
  <a href = "https://twitter.com/SergioReact418">
     <img src = "https://img.shields.io/twitter/url?label=follow&style=social&url=https%3A%2F%2Ftwitter.com%2FSergioReact418" />
  </a>
