// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Marketplace} from "../contracts/Marketplace.sol";
import "forge-std/src/Script.sol";

contract DeployMarketplace is Script {
    uint256 deployerPrivateKey;
    address accessTokenFactory;
    address[] rentCurrencies;
    address treasury;
    uint256 feePoints; 

    function setUp() public {
        deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        accessTokenFactory = 0x35a8483444947B2166Aa85837F97FaEf122f5ebb;
        treasury = 0x3F3786B67DC1874C3Bd8e8CD61F5eea87604470F;
        feePoints = 100; // 100/10000 = 10%
    }

    function run() public returns (address) {
        vm.startBroadcast(deployerPrivateKey);
        Marketplace martketplace = new Marketplace(
            vm.addr(deployerPrivateKey),
            accessTokenFactory,
            rentCurrencies,
            payable(treasury),
            feePoints
        );
        vm.stopBroadcast();
        return address(martketplace);
    }
}
