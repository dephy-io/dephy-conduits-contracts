// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import {Marketplace} from "../../contracts/Marketplace.sol";
import "forge-std/src/Script.sol";

contract DeployMarketplace is Script {
    uint256 deployerPrivateKey;

    address initialOwner;
    address productFactory;
    string name;
    string symbol;
    address[] rentCurrencies;
    address treasury;
    uint256 feePoints; 

    function setUp() public {
        deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        initialOwner = vm.addr(deployerPrivateKey);
        productFactory = 0x1dFC014B1852f0c81d11A3535335f1984cD4CE37;
        name = "Marketplace";
        symbol = "MKTP";
        treasury = 0x3F3786B67DC1874C3Bd8e8CD61F5eea87604470F;
        feePoints = 100; // 100/10000 = 10%
    }

    function run() public {
        vm.startBroadcast(deployerPrivateKey);
        new Marketplace(
            initialOwner,
            productFactory,
            name,
            symbol,
            rentCurrencies,
            payable(treasury),
            feePoints
        );
        vm.stopBroadcast();
    }
}
