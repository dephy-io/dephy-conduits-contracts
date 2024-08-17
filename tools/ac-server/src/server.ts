import express from "express";
import { ethers } from "ethers";
import IApplicationJson from "./IApplication.json";

const PORT = process.env.PORT || 3155;
const APPLICATION = process.env.APPLICATION || "0xed867DdA455093e40342F509f817494BC850a598";
const RPC = process.env.RPC || "https://base-sepolia.g.alchemy.com/v2/0ZS0OdXDqBpKt6wkusuFDyi0lLlTFRVf";

const provider = new ethers.providers.JsonRpcProvider(RPC);
const applicationContract = new ethers.Contract(
  APPLICATION,
  IApplicationJson.abi,
  provider
);

const app = express();

app.get("/access-control", async (req, res) => {
  let { device, user } = req.query;

  if (!device || !user) {
    return res.status(400).json({ error: "Missing required parameters" });
  }

  try {
    device = ethers.utils.getAddress(device as string);
    user = ethers.utils.getAddress(user as string);
  } catch (error) {
    return res.status(400).json({ error: "Address parsed error" });
  }

  try {
    const result = await applicationContract.isAccessible(device, user);
    res.json({ data: result });
  } catch (error) {
    console.error("Error:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
