"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const ethers_1 = require("ethers");
const yargs_1 = __importDefault(require("yargs"));
const helpers_1 = require("yargs/helpers");
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
const ACCESS_TOKEN_FACTORY_PATH = "../../../out/AccessTokenFactory.sol/AccessTokenFactory.json";
const ACCESS_TOKEN_PATH = "../../../out/AccessToken.sol/AccessToken.json";
(0, yargs_1.default)((0, helpers_1.hideBin)(process.argv))
    .command("createAccessToken", "Create an AccessToken for a given product address.", {
    rpc: { type: "string", demandOption: true },
    privatekey: { type: "string", demandOption: true },
    accessTokenFactory: { type: "string", demandOption: true },
    product: { type: "string", demandOption: true },
}, (args) => __awaiter(void 0, void 0, void 0, function* () {
    const wallet = new ethers_1.ethers.Wallet(args.privatekey, new ethers_1.ethers.providers.JsonRpcProvider(args.rpc));
    const accessTokenFactoryArtifactPath = path_1.default.resolve(__dirname, ACCESS_TOKEN_FACTORY_PATH);
    const accessTokenFactoryArtifact = JSON.parse(fs_1.default.readFileSync(accessTokenFactoryArtifactPath, "utf-8"));
    const accessTokenFactory = new ethers_1.ethers.Contract(args.accessTokenFactory, accessTokenFactoryArtifact.abi, wallet);
    let accessTokenAddress = yield accessTokenFactory.getAccessToken(args.product);
    if (accessTokenAddress === ethers_1.ethers.constants.AddressZero) {
        console.log("Creating AccessToken...");
        const tx = yield accessTokenFactory.createAccessToken(args.product);
        yield tx.wait();
        accessTokenAddress = yield accessTokenFactory.getAccessToken(args.product);
    }
    console.log(`AccessToken created at ${accessTokenAddress}`);
}))
    .command("mint", "Mint an AccessToken for a given product and tokenId.", {
    rpc: { type: "string", demandOption: true },
    privatekey: { type: "string", demandOption: true },
    accessTokenFactory: { type: "string", demandOption: true },
    product: { type: "string", demandOption: true },
    user: { type: "string", demandOption: true },
    tokenId: { type: "string", demandOption: true },
}, (args) => __awaiter(void 0, void 0, void 0, function* () {
    const wallet = new ethers_1.ethers.Wallet(args.privatekey, new ethers_1.ethers.providers.JsonRpcProvider(args.rpc));
    const accessTokenFactoryArtifactPath = path_1.default.resolve(__dirname, ACCESS_TOKEN_FACTORY_PATH);
    const accessTokenFactoryArtifact = JSON.parse(fs_1.default.readFileSync(accessTokenFactoryArtifactPath, "utf-8"));
    const accessTokenFactory = new ethers_1.ethers.Contract(args.accessTokenFactory, accessTokenFactoryArtifact.abi, wallet);
    const accessTokenAddress = yield accessTokenFactory.getAccessToken(args.product);
    const accessTokenArtifactPath = path_1.default.resolve(__dirname, ACCESS_TOKEN_PATH);
    const accessTokenArtifact = JSON.parse(fs_1.default.readFileSync(accessTokenArtifactPath, "utf-8"));
    const accessToken = new ethers_1.ethers.Contract(accessTokenAddress, accessTokenArtifact.abi, wallet);
    console.log("Minting AccessToken...");
    const tx = yield accessToken.mint(args.user, args.tokenId);
    yield tx.wait();
    console.log(`AccessToken minted to ${args.user} for tokenId ${args.tokenId}`);
}))
    .command("burn", "Burn an AccessToken for a given product and tokenId.", {
    rpc: { type: "string", demandOption: true },
    privatekey: { type: "string", demandOption: true },
    accessTokenFactory: { type: "string", demandOption: true },
    product: { type: "string", demandOption: true },
    tokenId: { type: "string", demandOption: true },
}, (args) => __awaiter(void 0, void 0, void 0, function* () {
    const wallet = new ethers_1.ethers.Wallet(args.privatekey, new ethers_1.ethers.providers.JsonRpcProvider(args.rpc));
    const accessTokenFactoryArtifactPath = path_1.default.resolve(__dirname, ACCESS_TOKEN_FACTORY_PATH);
    const accessTokenFactoryArtifact = JSON.parse(fs_1.default.readFileSync(accessTokenFactoryArtifactPath, "utf-8"));
    const accessTokenFactory = new ethers_1.ethers.Contract(args.accessTokenFactory, accessTokenFactoryArtifact.abi, wallet);
    const accessTokenAddress = yield accessTokenFactory.getAccessToken(args.product);
    const accessTokenArtifactPath = path_1.default.resolve(__dirname, ACCESS_TOKEN_PATH);
    const accessTokenArtifact = JSON.parse(fs_1.default.readFileSync(accessTokenArtifactPath, "utf-8"));
    const accessToken = new ethers_1.ethers.Contract(accessTokenAddress, accessTokenArtifact.abi, wallet);
    console.log("Burning AccessToken...");
    const tx = yield accessToken.burn(args.tokenId);
    yield tx.wait();
    console.log(`AccessToken with tokenId ${args.tokenId} burned`);
}))
    .command("accessControl", "Check if a user owns an AccessToken for a given product and tokenId.", {
    rpc: { type: "string", demandOption: true },
    accessTokenFactory: { type: "string", demandOption: true },
    product: { type: "string", demandOption: true },
    tokenId: { type: "string", demandOption: true },
    user: { type: "string", demandOption: true },
}, (args) => __awaiter(void 0, void 0, void 0, function* () {
    const provider = new ethers_1.ethers.providers.JsonRpcProvider(args.rpc);
    const accessTokenFactoryArtifactPath = path_1.default.resolve(__dirname, ACCESS_TOKEN_FACTORY_PATH);
    const accessTokenFactoryArtifact = JSON.parse(fs_1.default.readFileSync(accessTokenFactoryArtifactPath, "utf-8"));
    const accessTokenFactory = new ethers_1.ethers.Contract(args.accessTokenFactory, accessTokenFactoryArtifact.abi, provider);
    const accessTokenAddress = yield accessTokenFactory.getAccessToken(args.product);
    const accessTokenArtifactPath = path_1.default.resolve(__dirname, ACCESS_TOKEN_PATH);
    const accessTokenArtifact = JSON.parse(fs_1.default.readFileSync(accessTokenArtifactPath, "utf-8"));
    const accessToken = new ethers_1.ethers.Contract(accessTokenAddress, accessTokenArtifact.abi, provider);
    console.log("Checking AccessToken ownership...");
    const isOwned = yield accessToken.isUserOwned(args.user, args.tokenId);
    console.log(`User ${args.user} owns tokenId ${args.tokenId}: ${isOwned}`);
}))
    .help().argv;
