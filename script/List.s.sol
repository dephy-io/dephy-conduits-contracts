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
    string accessURI;

    function setUp() public {
        ownerPrivateKey = vm.envUint("PRIVATE_KEY");

        marketplace = Marketplace(0xe250f5d46395E42c9955E16CAc6C9dacCdD3B7dB);

        device = 0x013e6d465077BD8b6EF99fAE5E953A4054070945; // set your device here
        minRentalDays = 1; // set min rental days
        maxRentalDays = 99; // set max rental days
        rentCurrency = address(0); // only whitelisted currency, zero-address means eth(native token)
        dailyRent = 4*1e14; // set daily rent
        rentRecipient = vm.addr(ownerPrivateKey); // set rent receiver
        accessURI = "http://";
    }

    function run() public {
        vm.startBroadcast(ownerPrivateKey);
        (address product, uint256 tokenId) = marketplace.getDeviceBinding(device);
        IERC721(product).approve(
            address(marketplace),
            tokenId
        );
        marketplace.list(device, minRentalDays, maxRentalDays, rentCurrency, dailyRent, rentRecipient, accessURI);
        vm.stopBroadcast();
    }
}
