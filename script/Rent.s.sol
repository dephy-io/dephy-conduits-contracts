// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import {Marketplace} from "../../contracts/Marketplace.sol";
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
        marketplace = Marketplace(0xe250f5d46395E42c9955E16CAc6C9dacCdD3B7dB);

        device = 0xd34DfdE2bc41C7DaCBA160F10D61D4030971758C; // set your device here
        tenant = vm.addr(tenantPrivateKey); // set tenant address, default is caller
        rentalDays = marketplace.getListingInfo(device).minRentalDays;                       // set rental days, min value is min rental days set by device owner
        prepaidRent = rentalDays * marketplace.getListingInfo(device).dailyRent; // set prepaid rent, min value is rentalDays * dailyRent set by device owner
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
