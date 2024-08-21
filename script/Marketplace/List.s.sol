// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import {Marketplace} from "../../contracts/Marketplace.sol";
import {IMarketplaceStructs} from "../../contracts/interfaces/IMarketplaceStructs.sol";
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

        marketplace = Marketplace(0xd7B74EA2242e7e1918fc862997C30C7ef3Bd65C6);

        device = 0x407156bB8154C5BFA8808125cA981dc257eCed54; // set your device here
        minRentalDays = 2; // set min rental days
        maxRentalDays = 2; // set max rental days
        rentCurrency = address(0); // only whitelisted currency, zero-address means bnb(native token)
        dailyRent = 2*1e14; // set daily rent, here is 0.0001 BNB per day
        rentRecipient = vm.addr(ownerPrivateKey); // set rent receiver
    }

    function run() public {
        vm.startBroadcast(ownerPrivateKey);
        (address product, uint256 tokenId) = marketplace.APPLICATION().getDeviceBinding(device);
        IERC721(product).approve(
            address(marketplace),
            tokenId
        );
        marketplace.list(device, minRentalDays, maxRentalDays, rentCurrency, dailyRent, rentRecipient);
        vm.stopBroadcast();
    }
}
