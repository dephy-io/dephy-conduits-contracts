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

        marketplace = Marketplace(0xEdeE6f1E0315d0872CF824A71BC9d5E3Ef5f0b10);

        device = 0xd34DfdE2bc41C7DaCBA160F10D61D4030971758C; // set your device here
        minRentalDays = 1; // set min rental days
        maxRentalDays = 10; // set max rental days
        rentCurrency = address(0); // only whitelisted currency, zero-address means eth(native token)
        dailyRent = 4*1e14; // set daily rent
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
