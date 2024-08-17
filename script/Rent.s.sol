// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Marketplace} from "../contracts/Marketplace.sol";
import {IMarketplaceStructs} from "../contracts/interfaces/IMarketplaceStructs.sol";
import "forge-std/src/Script.sol";

contract Rent is Script {
    uint256 tenantPrivateKey;

    Marketplace marketplace;

    // rent params
    address device;
    address tenant;
    uint256 rentalDays;
    uint256 prepaidRent;

    function setUp() public {
        tenantPrivateKey = 0x0c6cd1d3bd57be803801f5250eeb8374a30ac11537746995ca3da2a90676da24;
        marketplace = Marketplace(0x5606119e87B61228485b761b09AA7A48f7f48980);

        device = 0x32EF0DB4EF2Bd4Ef6473243796ee6b14A9937B64; // set your device here
        tenant = vm.addr(tenantPrivateKey); // set tenant address, default is caller
        rentalDays = 5;                       // set rental days, min value is min rental days set by device owner
        prepaidRent = 5 * marketplace.getListingInfo(device).dailyRent; // set prepaid rent, min value is rentalDays * dailyRent set by device owner
    }

    function run() public {
        vm.startBroadcast(tenantPrivateKey);
        if (marketplace.getListingInfo(device).rentCurrency == marketplace.NATIVE_TOKEN()) {
            marketplace.rent{value: prepaidRent}(device, tenant, rentalDays, prepaidRent);
        } else {
            marketplace.rent(device, tenant, rentalDays, prepaidRent);
        }
        vm.stopBroadcast();
    }
}
