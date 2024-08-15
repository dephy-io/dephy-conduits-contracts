// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessTokenFactory} from "../contracts/AccessTokenFactory.sol";
import "forge-std/src/Script.sol";

contract CreateAccessToken is Script {
    uint256 deployerPrivateKey;
    AccessTokenFactory accessTokenFactory;
    IProductFactory productFactory;
    address device;

    function setUp() public {
        deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        accessTokenFactory = AccessTokenFactory(0x34D22CbdCD41E06af4BDB87BFc67c58E83DcE922);
        productFactory = IProductFactory(0x1dFC014B1852f0c81d11A3535335f1984cD4CE37);
        device = 0xA7fE098F2D4D2cD6bA158E5470d9231AC223bA06;        // set your device here
    }

    function run() public returns (address) {
        IProductFactory.DeviceBinding memory deviceBinding = productFactory.getDeviceBinding(device);
        vm.startBroadcast(deployerPrivateKey);
        address accessToken = accessTokenFactory.createAccessToken(deviceBinding.product);
        console.log("AccessToken:", accessToken);
        vm.stopBroadcast();
        return address(accessTokenFactory);
    }
}

interface IProductFactory {
    struct DeviceBinding {
        address product;
        uint256 tokenId;
    }

    /**
     * @notice Returns the product address and token ID for a device.
     * @param device Address of the device.
     * @return DevieInfo Product address and Token ID associated with the device.
     */
    function getDeviceBinding(
        address device
    ) external view returns (DeviceBinding memory);
}
