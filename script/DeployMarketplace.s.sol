// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Marketplace} from "../contracts/Marketplace.sol";
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
        application = 0xed867DdA455093e40342F509f817494BC850a598;
        treasury = 0x3F3786B67DC1874C3Bd8e8CD61F5eea87604470F;
        feePoints = 100; // 100/10000 = 10%
    }

    function run() public returns (address) {
        vm.startBroadcast(deployerPrivateKey);
        Marketplace martketplace = new Marketplace(
            initialOwner,
            application,
            rentCurrencies,
            payable(treasury),
            feePoints
        );
        vm.stopBroadcast();
        return address(martketplace);
    }
}
