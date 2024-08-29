// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import {Marketplace} from "../../contracts/Marketplace.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "forge-std/src/Script.sol";

contract List is Script {
    uint256 ownerPrivateKey;

    Marketplace marketplace;

    // list params
    address device;
    uint256 minRentalDays;
    uint256 maxRentalDays;
    address rentCurrency;
    uint256 dailyRent;
    address rentRecipient;

    function setUp() public {
        ownerPrivateKey = vm.envUint("PRIVATE_KEY");

        marketplace = Marketplace(0x397C2649409F4dA69e8191e75A5Fe7Bb26cde597);

        device = 0x683C76714F1560BdB37EEf318F725EF44382C279; // set your device here
        minRentalDays = 2; // set min rental days
        maxRentalDays = 4; // set max rental days
        rentCurrency = address(0); // only whitelisted currency, zero-address means eth(native token)
        dailyRent = 7*1e12; // set daily rent
        rentRecipient = vm.addr(ownerPrivateKey); // set rent receiver
    }

    function run() public {
        vm.startBroadcast(ownerPrivateKey);
        (address product, uint256 tokenId) = marketplace.getDeviceBinding(device);
        IERC721(product).approve(
            address(marketplace),
            tokenId
        );
        marketplace.list(device, minRentalDays, maxRentalDays, rentCurrency, dailyRent, rentRecipient);
        vm.stopBroadcast();
    }
}
