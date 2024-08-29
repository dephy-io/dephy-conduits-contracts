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
    string accessURI;

    function setUp() public {
        tenantPrivateKey = 0x0c6cd1d3bd57be803801f5250eeb8374a30ac11537746995ca3da2a90676da24;
        marketplace = Marketplace(0x397C2649409F4dA69e8191e75A5Fe7Bb26cde597);

        device = 0x34Fa3Ed7A6Ca97822867eB52bF5dD70Bd87FD96C; // set your device here
        tenant = vm.addr(tenantPrivateKey); // set tenant address, default is caller
        rentalDays = marketplace.getListingInfo(device).minRentalDays;                       // set rental days, min value is min rental days set by device owner
        prepaidRent = rentalDays * marketplace.getListingInfo(device).dailyRent; // set prepaid rent, min value is rentalDays * dailyRent set by device owner
        accessURI = "http://";
    }

    function run() public {
        vm.startBroadcast(tenantPrivateKey);
        if (marketplace.getListingInfo(device).rentCurrency == marketplace.NATIVE_TOKEN()) {
            marketplace.rent{value: prepaidRent}(device, tenant, rentalDays, prepaidRent, accessURI);
        } else {
            marketplace.rent(device, tenant, rentalDays, prepaidRent, accessURI);
        }
        vm.stopBroadcast();
    }
}
