// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Marketplace} from "../contracts/Marketplace.sol";
import {IMarketplaceStructs} from "../contracts/interfaces/IMarketplaceStructs.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "forge-std/src/Script.sol";

contract List is Script {
    uint256 deployerPrivateKey;

    Marketplace marketplace;

    // list params
    address device;
    uint256 minRentalDays;
    uint256 maxRentalDays;
    address rentCurrency;
    uint256 dailyRent;
    address rentRecipient;

    function setUp() public {
        deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        marketplace = Marketplace(0xb26e7D044fcA8d4590068AD53646c8127ffe4da5);

        device = 0xA7fE098F2D4D2cD6bA158E5470d9231AC223bA06; // set your device here
        minRentalDays = 5; // set min rental days
        maxRentalDays = 10; // set max rental days
        rentCurrency = address(0); // only whitelisted currency, zero-address means bnb(native token)
        dailyRent = 1e14; // set daily rent, here is 0.0001 BNB per day
        rentRecipient = vm.addr(deployerPrivateKey); // set rent receiver
    }

    function run() public {
        vm.startBroadcast(deployerPrivateKey);
        (address product, uint256 tokenId) = marketplace.APPLICATION().getDeviceBinding(device);
        IERC721(product).approve(
            address(marketplace),
            tokenId
        );
        marketplace.list(device, minRentalDays, maxRentalDays, rentCurrency, dailyRent, rentRecipient);
        vm.stopBroadcast();
    }
}
