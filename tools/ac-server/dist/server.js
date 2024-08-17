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
const IApplication_json_1 = __importDefault(require("./IApplication.json"));
const PORT = process.env.PORT || 3155;
const APPLICATION = process.env.APPLICATION || "0xed867DdA455093e40342F509f817494BC850a598";
const RPC = process.env.RPC || "https://base-sepolia.g.alchemy.com/v2/0ZS0OdXDqBpKt6wkusuFDyi0lLlTFRVf";
const provider = new ethers_1.ethers.providers.JsonRpcProvider(RPC);
const applicationContract = new ethers_1.ethers.Contract(APPLICATION, IApplication_json_1.default.abi, provider);
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
        const result = yield applicationContract.isAccessible(device, user);
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
