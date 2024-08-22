// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import {Marketplace} from "../../contracts/Marketplace.sol";
import "forge-std/src/Script.sol";

contract DeployMarketplace is Script {
    uint256 deployerPrivateKey;

    address initialOwner;
    address application;
    address[] rentCurrencies;
    address treasury;
    uint256 feePoints; 

    function setUp() public {
        deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        initialOwner = vm.addr(deployerPrivateKey);
        application = 0x704876F802d41c52753Ef708B336d5e572db77A3;
        treasury = 0x3F3786B67DC1874C3Bd8e8CD61F5eea87604470F;
        feePoints = 100; // 100/10000 = 10%
    }

    function run() public {
        vm.startBroadcast(deployerPrivateKey);
        new Marketplace(
            initialOwner,
            application,
            rentCurrencies,
            payable(treasury),
            feePoints
        );
        vm.stopBroadcast();
    }
}
