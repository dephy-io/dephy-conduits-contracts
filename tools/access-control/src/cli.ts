import { ethers } from "ethers";
import yargs from "yargs";
import { hideBin } from "yargs/helpers";
import fs from "fs";
import path from "path";

const ACCESS_TOKEN_FACTORY_PATH = "../../../out/AccessTokenFactory.sol/AccessTokenFactory.json";
const ACCESS_TOKEN_PATH = "../../../out/AccessToken.sol/AccessToken.json";

yargs(hideBin(process.argv))
  .command(
    "createAccessToken",
    "Create an AccessToken for a given product address.",
    {
      rpc: { type: "string", demandOption: true },
      privatekey: { type: "string", demandOption: true },
      accessTokenFactory: { type: "string", demandOption: true },
      product: { type: "string", demandOption: true },
    },
    async (args) => {
      const wallet = new ethers.Wallet(args.privatekey, new ethers.providers.JsonRpcProvider(args.rpc));

      const accessTokenFactoryArtifactPath = path.resolve(
        __dirname,
        ACCESS_TOKEN_FACTORY_PATH
      );
      const accessTokenFactoryArtifact = JSON.parse(
        fs.readFileSync(accessTokenFactoryArtifactPath, "utf-8")
      );

      const accessTokenFactory = new ethers.Contract(
        args.accessTokenFactory,
        accessTokenFactoryArtifact.abi,
        wallet
      );

      let accessTokenAddress = await accessTokenFactory.getAccessToken(args.product);
      if(accessTokenAddress === ethers.constants.AddressZero) {
        console.log("Creating AccessToken...");
        const tx = await accessTokenFactory.createAccessToken(args.product);
        await tx.wait();
        accessTokenAddress = await accessTokenFactory.getAccessToken(args.product);
      }
      console.log(`AccessToken created at ${accessTokenAddress}`);
    }
  )
  .command(
    "mint",
    "Mint an AccessToken for a given product and tokenId.",
    {
      rpc: { type: "string", demandOption: true },
      privatekey: { type: "string", demandOption: true },
      accessTokenFactory: { type: "string", demandOption: true },
      product: { type: "string", demandOption: true },
      user: { type: "string", demandOption: true },
      tokenId: { type: "string", demandOption: true },
    },
    async (args) => {
      const wallet = new ethers.Wallet(args.privatekey, new ethers.providers.JsonRpcProvider(args.rpc));

      const accessTokenFactoryArtifactPath = path.resolve(
        __dirname,
        ACCESS_TOKEN_FACTORY_PATH
      );
      const accessTokenFactoryArtifact = JSON.parse(
        fs.readFileSync(accessTokenFactoryArtifactPath, "utf-8")
      );

      const accessTokenFactory = new ethers.Contract(
        args.accessTokenFactory,
        accessTokenFactoryArtifact.abi,
        wallet
      );

      const accessTokenAddress = await accessTokenFactory.getAccessToken(args.product);

      const accessTokenArtifactPath = path.resolve(
        __dirname,
        ACCESS_TOKEN_PATH
      );
      const accessTokenArtifact = JSON.parse(
        fs.readFileSync(accessTokenArtifactPath, "utf-8")
      );

      const accessToken = new ethers.Contract(
        accessTokenAddress,
        accessTokenArtifact.abi,
        wallet
      );

      console.log("Minting AccessToken...");
      const tx = await accessToken.mint(args.user, args.tokenId);
      await tx.wait();
      console.log(`AccessToken minted to ${args.user} for tokenId ${args.tokenId}`);
    }
  )
  .command(
    "burn",
    "Burn an AccessToken for a given product and tokenId.",
    {
      rpc: { type: "string", demandOption: true },
      privatekey: { type: "string", demandOption: true },
      accessTokenFactory: { type: "string", demandOption: true },
      product: { type: "string", demandOption: true },
      tokenId: { type: "string", demandOption: true },
    },
    async (args) => {
      const wallet = new ethers.Wallet(args.privatekey, new ethers.providers.JsonRpcProvider(args.rpc));

      const accessTokenFactoryArtifactPath = path.resolve(
        __dirname,
        ACCESS_TOKEN_FACTORY_PATH
      );
      const accessTokenFactoryArtifact = JSON.parse(
        fs.readFileSync(accessTokenFactoryArtifactPath, "utf-8")
      );

      const accessTokenFactory = new ethers.Contract(
        args.accessTokenFactory,
        accessTokenFactoryArtifact.abi,
        wallet
      );

      const accessTokenAddress = await accessTokenFactory.getAccessToken(args.product);

      const accessTokenArtifactPath = path.resolve(
        __dirname,
        ACCESS_TOKEN_PATH
      );
      const accessTokenArtifact = JSON.parse(
        fs.readFileSync(accessTokenArtifactPath, "utf-8")
      );

      const accessToken = new ethers.Contract(
        accessTokenAddress,
        accessTokenArtifact.abi,
        wallet
      );

      console.log("Burning AccessToken...");
      const tx = await accessToken.burn(args.tokenId);
      await tx.wait();
      console.log(`AccessToken with tokenId ${args.tokenId} burned`);
    }
  )
  .command(
    "accessControl",
    "Check if a user owns an AccessToken for a given product and tokenId.",
    {
      rpc: { type: "string", demandOption: true },
      accessTokenFactory: { type: "string", demandOption: true },
      product: { type: "string", demandOption: true },
      tokenId: { type: "string", demandOption: true },
      user: { type: "string", demandOption: true },
    },
    async (args) => {
      const provider = new ethers.providers.JsonRpcProvider(args.rpc);

      const accessTokenFactoryArtifactPath = path.resolve(
        __dirname,
        ACCESS_TOKEN_FACTORY_PATH
      );
      const accessTokenFactoryArtifact = JSON.parse(
        fs.readFileSync(accessTokenFactoryArtifactPath, "utf-8")
      );

      const accessTokenFactory = new ethers.Contract(
        args.accessTokenFactory,
        accessTokenFactoryArtifact.abi,
        provider
      );

      const accessTokenAddress = await accessTokenFactory.getAccessToken(args.product);

      const accessTokenArtifactPath = path.resolve(
        __dirname,
        ACCESS_TOKEN_PATH
      );
      const accessTokenArtifact = JSON.parse(
        fs.readFileSync(accessTokenArtifactPath, "utf-8")
      );

      const accessToken = new ethers.Contract(
        accessTokenAddress,
        accessTokenArtifact.abi,
        provider
      );

      console.log("Checking AccessToken ownership...");
      const isOwned = await accessToken.isUserOwned(args.user, args.tokenId);
      console.log(`User ${args.user} owns tokenId ${args.tokenId}: ${isOwned}`);
    }
  )
  .help().argv;
