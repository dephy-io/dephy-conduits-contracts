// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Marketplace} from "../../contracts/Marketplace.sol";
import {IMarketplaceStructs} from "../../contracts/interfaces/IMarketplaceStructs.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "forge-std/src/Script.sol";

contract Delist is Script {
    uint256 ownerPrivateKey;

    Marketplace marketplace;

    // delist params
    address device;

    function setUp() public {
        ownerPrivateKey = vm.envUint("PRIVATE_KEY");

        marketplace = Marketplace(0x5606119e87B61228485b761b09AA7A48f7f48980);

        device = 0x407156bB8154C5BFA8808125cA981dc257eCed54; // set your device here
    }

    function run() public {
        vm.startBroadcast(ownerPrivateKey);
        marketplace.delist(device);
        vm.stopBroadcast();
    }
}
