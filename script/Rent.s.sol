// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Marketplace} from "../contracts/Marketplace.sol";
import {IMarketplaceStructs} from "../contracts/interfaces/IMarketplaceStructs.sol";
import "forge-std/src/Script.sol";

contract Rent is Script {
    uint256 deployerPrivateKey;

    Marketplace marketplace;

    // rent params
    address device;
    address tenant;
    uint256 rentalDays;
    uint256 prepaidRent;

    function setUp() public {
        deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        marketplace = Marketplace(0xb26e7D044fcA8d4590068AD53646c8127ffe4da5);

        device = 0xA7fE098F2D4D2cD6bA158E5470d9231AC223bA06; // set your device here
        tenant = vm.addr(deployerPrivateKey); // set tenant address, default is caller
        rentalDays = 5;                       // set rental days, min value is min rental days set by device owner
        prepaidRent = 5 * marketplace.getListingInfo(device).dailyRent; // set prepaid rent, min value is rentalDays * dailyRent set by device owner
    }

    function run() public {
        vm.startBroadcast(deployerPrivateKey);
        if (marketplace.getListingInfo(device).rentCurrency == marketplace.NATIVE_TOKEN()) {
            marketplace.rent{value: prepaidRent}(device, tenant, rentalDays, prepaidRent);
        } else {
            marketplace.rent(device, tenant, rentalDays, prepaidRent);
        }
        vm.stopBroadcast();
    }
}
