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
const express_1 = __importDefault(require("express"));
const ethers_1 = require("ethers");
const AccessTokenFactory_json_1 = __importDefault(require("./abi/AccessTokenFactory.json"));
const AccessToken_json_1 = __importDefault(require("./abi/AccessToken.json"));
const ProductFactory_json_1 = __importDefault(require("./abi/ProductFactory.json"));
const Product_json_1 = __importDefault(require("./abi/Product.json"));
const PORT = process.env.PORT || 3155;
const PRODUCT_FACTORY = "0x1dFC014B1852f0c81d11A3535335f1984cD4CE37";
const ACCESS_TOKEN_FACTORY = "0x34D22CbdCD41E06af4BDB87BFc67c58E83DcE922";
const RPC = "https://base-sepolia.g.alchemy.com/v2/0ZS0OdXDqBpKt6wkusuFDyi0lLlTFRVf";
const provider = new ethers_1.ethers.providers.JsonRpcProvider(RPC);
const productFactoryContract = new ethers_1.ethers.Contract(PRODUCT_FACTORY, ProductFactory_json_1.default, provider);
const accessTokenFactoryContract = new ethers_1.ethers.Contract(ACCESS_TOKEN_FACTORY, AccessTokenFactory_json_1.default, provider);
const app = (0, express_1.default)();
app.get("/access-control", (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    let { device, user } = req.query;
    if (!device || !user) {
        return res.status(400).json({ error: "Missing required parameters" });
    }
    try {
        device = ethers_1.ethers.utils.getAddress(device);
        user = ethers_1.ethers.utils.getAddress(user);
    }
    catch (error) {
        return res.status(400).json({ error: "Address parsed error" });
    }
    try {
        let result;
        const { product, tokenId } = yield productFactoryContract.getDeviceBinding(device);
        if (product === ethers_1.ethers.constants.AddressZero) {
            result = false;
        }
        else {
            const productContract = new ethers_1.ethers.Contract(product, Product_json_1.default, provider);
            const owner = yield productContract.ownerOf(tokenId);
            if (owner === user) {
                result = true;
            }
            else {
                const accessTokenAddress = yield accessTokenFactoryContract.getAccessToken(product);
                const accessTokenContract = new ethers_1.ethers.Contract(accessTokenAddress, AccessToken_json_1.default, provider);
                if (accessTokenAddress === ethers_1.ethers.constants.AddressZero) {
                    result = false;
                }
                else {
                    result = yield accessTokenContract.isUserOwned(user, tokenId);
                }
            }
        }
        res.json({ data: result });
    }
    catch (error) {
        console.error("Error:", error);
        res.status(500).json({ error: "Internal Server Error" });
    }
}));
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
