// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessTokenFactory} from "../contracts/AccessTokenFactory.sol";
import "forge-std/src/Script.sol";

contract DeployAccessTokenFactory is Script {
    function run() public returns (address) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        AccessTokenFactory factory = new AccessTokenFactory();
        vm.stopBroadcast();
        return address(factory);
    }
}
