// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import {Marketplace} from "../../contracts/Marketplace.sol";
import "forge-std/src/Script.sol";

contract Relist is Script {
    uint256 ownerPrivateKey;

    Marketplace marketplace;

    // relist params
    address device;
    uint256 minRentalDays;
    uint256 maxRentalDays;
    address rentCurrency;
    uint256 dailyRent;
    address rentRecipient;

    function setUp() public {
        ownerPrivateKey = vm.envUint("PRIVATE_KEY");

        marketplace = Marketplace(0xe250f5d46395E42c9955E16CAc6C9dacCdD3B7dB);

        device = 0x407156bB8154C5BFA8808125cA981dc257eCed54; // set your device here
        minRentalDays = 2; // set min rental days
        maxRentalDays = 2; // set max rental days
        rentCurrency = address(0); // only whitelisted currency, zero-address means bnb(native token)
        dailyRent = 2*1e10; // set daily rent, here is 0.0001 BNB per day
        rentRecipient = vm.addr(ownerPrivateKey); // set rent receiver
    }

    function run() public {
        vm.startBroadcast(ownerPrivateKey);
        marketplace.relist(device, minRentalDays, maxRentalDays, rentCurrency, dailyRent, rentRecipient);
        vm.stopBroadcast();
    }
}
