import express from "express";
// import axios from "axios";
import { ethers } from "ethers";
import IApplicationJson from "./IApplication.json";
import AccessIdentitiesJson from "./AccessIdentities.json";

// const NOTIFY_API = process.env.NOTIFY_API || "https://localhost:1234/notify";
const DEVICE = process.env.DEVICE;
const PORT = process.env.PORT || 3155;
const ACCESS_IDENTITIES =
  process.env.ACCESS_IDENTITIES || "0x4Cd640e4177a5d86B06BDB147E7efECFf3E478b3";
const APPLICATION =
  process.env.APPLICATION || "0xed867DdA455093e40342F509f817494BC850a598";
const RPC =
  process.env.RPC ||
  "https://base-sepolia.g.alchemy.com/v2/0ZS0OdXDqBpKt6wkusuFDyi0lLlTFRVf";

if (!DEVICE) {
  throw new Error("env variable `DEVICE` undefined");
}

const provider = new ethers.providers.JsonRpcProvider(RPC);
const applicationContract = new ethers.Contract(
  APPLICATION,
  IApplicationJson.abi,
  provider
);
const accessIdentitiesContract = new ethers.Contract(
  ACCESS_IDENTITIES,
  AccessIdentitiesJson.abi,
  provider
);

// applicationContract.on("Transfer", async (from: string, to: string, tokenId: ethers.BigNumber, event) => {
//   if (from !== ethers.constants.AddressZero) {
//     console.log(`Transfer from ${from} to ${to}, tokenId: ${tokenId.toString()}`);
//     const response = await axios.post(NOTIFY_API, {from});
//     console.log(`Notification[transfer] sent, response status: ${response.status}`);
//   }
//   if (to === ethers.constants.AddressZero) {
//     console.log(`Token ${tokenId.toString()} burned from ${from}`);
//     const response = await axios.post(NOTIFY_API, {from});
//     console.log(`Notification[burn] sent, response status: ${response.status}`);
//   }
// });

let cachedIdentities: {
  prefix: string;
  digest: string;
}[] = [];

const updateIdenntities = async () => {
  try {
    const appDeviceOwner = await applicationContract.getAppDeviceOwner(DEVICE);
    const identities = await accessIdentitiesContract.getIdentities(
      appDeviceOwner
    );
    cachedIdentities = identities;
  } catch (error) {
    console.error("Error in program:", error);
  }
}

updateIdenntities();
setInterval(updateIdenntities, 60 * 1000);

const app = express();

app.get("/access", async (req, res) => {
  let { peer_id } = req.query;

  if (!peer_id) {
    return res.status(400).json({ error: "Missing required parameters" });
  }

  try {
    const data = !!cachedIdentities.find(
      (identity) => identity.digest === peer_id
    );
    res.json({ data });
  } catch (error) {
    console.error("Error:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
