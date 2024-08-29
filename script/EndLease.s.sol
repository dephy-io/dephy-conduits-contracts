// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import {Marketplace} from "../../contracts/Marketplace.sol";
import "forge-std/src/Script.sol";

contract EndLease is Script {
    uint256 ownerPrivateKey;

    Marketplace marketplace;

    // withdraw params
    address device;

    function setUp() public {
        ownerPrivateKey = vm.envUint("PRIVATE_KEY");

        marketplace = Marketplace(0x397C2649409F4dA69e8191e75A5Fe7Bb26cde597);

        device = 0x15A02419160FfdAF3a5d77Ea7e3812ebcC4ED8d5; // set your device here
    }

    function run() public {
        vm.startBroadcast(ownerPrivateKey);
        marketplace.endLease(device);
        vm.stopBroadcast();
    }
}
