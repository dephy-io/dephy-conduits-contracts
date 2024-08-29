// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import {Marketplace} from "../../contracts/Marketplace.sol";
import "forge-std/src/Script.sol";

contract Delist is Script {
    uint256 ownerPrivateKey;

    Marketplace marketplace;

    // delist params
    address device;

    function setUp() public {
        ownerPrivateKey = vm.envUint("PRIVATE_KEY");

        marketplace = Marketplace(0xEdeE6f1E0315d0872CF824A71BC9d5E3Ef5f0b10);

        device = 0x407156bB8154C5BFA8808125cA981dc257eCed54; // set your device here
    }

    function run() public {
        vm.startBroadcast(ownerPrivateKey);
        marketplace.delist(device);
        vm.stopBroadcast();
    }
}
