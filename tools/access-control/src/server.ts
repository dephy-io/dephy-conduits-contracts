import express from "express";
import { ethers } from "ethers";
import AccessTokenFactoryAbi from "./abi/AccessTokenFactory.json";
import AccessTokenAbi from "./abi/AccessToken.json";
import ProductFactoryAbi from "./abi/ProductFactory.json";
import ProductAbi from "./abi/Product.json";

const PORT = process.env.PORT || 3155;
const PRODUCT_FACTORY = "0x1dFC014B1852f0c81d11A3535335f1984cD4CE37";
const ACCESS_TOKEN_FACTORY = "0x34D22CbdCD41E06af4BDB87BFc67c58E83DcE922";
const RPC =
  "https://base-sepolia.g.alchemy.com/v2/0ZS0OdXDqBpKt6wkusuFDyi0lLlTFRVf";

const provider = new ethers.providers.JsonRpcProvider(RPC);
const productFactoryContract = new ethers.Contract(
  PRODUCT_FACTORY,
  ProductFactoryAbi,
  provider
);
const accessTokenFactoryContract = new ethers.Contract(
  ACCESS_TOKEN_FACTORY,
  AccessTokenFactoryAbi,
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
    let result: boolean;
    const { product, tokenId } = await productFactoryContract.getDeviceBinding(
      device
    );
    if (product === ethers.constants.AddressZero) {
      result = false;
    } else {
      const productContract = new ethers.Contract(
        product,
        AccessTokenAbi,
        provider
      );
      const owner = await productContract.ownerOf(tokenId);
      if (owner === user) {
        result = true;
      } else {
        const accessTokenAddress =
          await accessTokenFactoryContract.getAccessToken(product);
        const accessTokenContract = new ethers.Contract(
          accessTokenAddress,
          AccessTokenAbi,
          provider
        );
        if (accessTokenAddress === ethers.constants.AddressZero) {
          result = false;
        } else {
          result = await accessTokenContract.isUserOwned(user, tokenId);
        }
      }
    }
    res.json({ data: result });
  } catch (error) {
    console.error("Error:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
