import { ethers } from "ethers";
import yargs from "yargs";
import { hideBin } from "yargs/helpers";
import { Marketplace__factory } from "./generated";

yargs(hideBin(process.argv))
  .command(
    "list",
    "List a device on the marketplace",
    {
      rpc: { type: "string", demandOption: true },
      privatekey: { type: "string", demandOption: true },
      marketplace: { type: "string", demandOption: true },
      device: { type: "string", demandOption: true },
      minRentalDays: { type: "number", demandOption: true },
      maxRentalDays: { type: "number", demandOption: true },
      rentCurrency: { type: "string", demandOption: true },
      dailyRent: { type: "string", demandOption: true },
      rentRecipient: { type: "string", demandOption: true },
      accessURI: { type: "string", demandOption: true },
    },
    async (args) => {
      const contract = Marketplace__factory.connect(
        args.marketplace,
        new ethers.Wallet(
          args.privatekey,
          new ethers.providers.JsonRpcProvider(args.rpc)
        )
      );

      const tx = await contract.list(
        args.device,
        args.minRentalDays,
        args.maxRentalDays,
        args.rentCurrency,
        ethers.utils.parseUnits(args.dailyRent, 18),
        args.rentRecipient,
        args.accessURI
      );
      console.log(`List transaction sent: ${tx.hash}`);
      await tx.wait();
      console.log("Device listed successfully.");
    }
  )
  .command(
    "delist",
    "Delist a device from the marketplace",
    {
      rpc: { type: "string", demandOption: true },
      privatekey: { type: "string", demandOption: true },
      marketplace: { type: "string", demandOption: true },
      device: { type: "string", demandOption: true },
    },
    async (args) => {
      const contract = Marketplace__factory.connect(
        args.marketplace,
        new ethers.Wallet(
          args.privatekey,
          new ethers.providers.JsonRpcProvider(args.rpc)
        )
      );

      const tx = await contract.delist(args.device);
      console.log(`Delist transaction sent: ${tx.hash}`);
      await tx.wait();
      console.log("Device delisted successfully.");
    }
  )
  .command(
    "relist",
    "Relist a device on the marketplace",
    {
      rpc: { type: "string", demandOption: true },
      privatekey: { type: "string", demandOption: true },
      marketplace: { type: "string", demandOption: true },
      device: { type: "string", demandOption: true },
      minRentalDays: { type: "number", demandOption: true },
      maxRentalDays: { type: "number", demandOption: true },
      rentCurrency: { type: "string", demandOption: true },
      dailyRent: { type: "string", demandOption: true },
      rentRecipient: { type: "string", demandOption: true },
    },
    async (args) => {
      const contract = Marketplace__factory.connect(
        args.marketplace,
        new ethers.Wallet(
          args.privatekey,
          new ethers.providers.JsonRpcProvider(args.rpc)
        )
      );

      const tx = await contract.relist(
        args.device,
        args.minRentalDays,
        args.maxRentalDays,
        args.rentCurrency,
        ethers.utils.parseUnits(args.dailyRent, 18),
        args.rentRecipient
      );
      console.log(`Relist transaction sent: ${tx.hash}`);
      await tx.wait();
      console.log("Device relisted successfully.");
    }
  )
  .command(
    "rent",
    "Rent a device on the marketplace",
    {
      rpc: { type: "string", demandOption: true },
      privatekey: { type: "string", demandOption: true },
      marketplace: { type: "string", demandOption: true },
      device: { type: "string", demandOption: true },
      tenant: { type: "string", demandOption: true },
      rentalDays: { type: "number", demandOption: true },
      prepaidRent: { type: "string", demandOption: true },
    },
    async (args) => {
      const contract = Marketplace__factory.connect(
        args.marketplace,
        new ethers.Wallet(
          args.privatekey,
          new ethers.providers.JsonRpcProvider(args.rpc)
        )
      );

      const prepaidRent = ethers.utils.parseUnits(args.prepaidRent, 18);
      const tx = await contract.rent(
        args.device,
        args.tenant,
        args.rentalDays,
        prepaidRent,
        {
          value: prepaidRent,
        }
      );
      console.log(`Rent transaction sent: ${tx.hash}`);
      await tx.wait();
      console.log("Device rented successfully.");
    }
  )
  .command(
    "payRent",
    "Pay rent for a device",
    {
      rpc: { type: "string", demandOption: true },
      privatekey: { type: "string", demandOption: true },
      marketplace: { type: "string", demandOption: true },
      device: { type: "string", demandOption: true },
      rent: { type: "string", demandOption: true },
    },
    async (args) => {
      const contract = Marketplace__factory.connect(
        args.marketplace,
        new ethers.Wallet(
          args.privatekey,
          new ethers.providers.JsonRpcProvider(args.rpc)
        )
      );

      const rent = ethers.utils.parseUnits(args.rent, 18);
      const tx = await contract.payRent(args.device, rent, {
        value: rent,
      });
      console.log(`PayRent transaction sent: ${tx.hash}`);
      await tx.wait();
      console.log("Rent paid successfully.");
    }
  )
  .command(
    "endLease",
    "End the lease of a device",
    {
      rpc: { type: "string", demandOption: true },
      privatekey: { type: "string", demandOption: true },
      marketplace: { type: "string", demandOption: true },
      device: { type: "string", demandOption: true },
    },
    async (args) => {
      const contract = Marketplace__factory.connect(
        args.marketplace,
        new ethers.Wallet(
          args.privatekey,
          new ethers.providers.JsonRpcProvider(args.rpc)
        )
      );

      const tx = await contract.endLease(args.device);
      console.log(`EndLease transaction sent: ${tx.hash}`);
      await tx.wait();
      console.log("Lease ended successfully.");
    }
  )
  .command(
    "withdraw",
    "Withdraw a device from the marketplace",
    {
      rpc: { type: "string", demandOption: true },
      privatekey: { type: "string", demandOption: true },
      marketplace: { type: "string", demandOption: true },
      device: { type: "string", demandOption: true },
    },
    async (args) => {
      const contract = Marketplace__factory.connect(
        args.marketplace,
        new ethers.Wallet(
          args.privatekey,
          new ethers.providers.JsonRpcProvider(args.rpc)
        )
      );

      const tx = await contract.withdraw(args.device);
      console.log(`Withdraw transaction sent: ${tx.hash}`);
      await tx.wait();
      console.log("Device withdrawn successfully.");
    }
  )
  .help().argv;
