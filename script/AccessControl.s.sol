// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessTokenFactory} from "../contracts/AccessTokenFactory.sol";
import {AccessToken} from "../contracts/AccessToken.sol";
import {Marketplace} from "../contracts/Marketplace.sol";
import {IMarketplaceStructs} from "../contracts/interfaces/IMarketplaceStructs.sol";
import "forge-std/src/Script.sol";

contract Rent is Script {
    uint256 deployerPrivateKey;
    Marketplace marketplace;
    IProductFactory productFactory;
    AccessTokenFactory accessTokenFactory;
    address device;
    IProductFactory.DeviceBinding deviceBinding;
    AccessToken accessToken;
    address user;

    function setUp() public {
        deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        marketplace = Marketplace(0x647d77324E241709BaF63D7f96F0C19ecA06E2e0);
        productFactory = IProductFactory(0x8E360F40c7875e096e0DbFe0cC01d1db5aFB78B6);
        accessTokenFactory = AccessTokenFactory(0x35a8483444947B2166Aa85837F97FaEf122f5ebb);
        device = 0xA7fE098F2D4D2cD6bA158E5470d9231AC223bA06;        // set device here
        user = 0xD0167B1cc6CAb1e4e7C6f38d09EA35171d00b68e; // set user device here
        deviceBinding = productFactory.getDeviceBinding(device);
        accessToken = AccessToken(accessTokenFactory.getAccessToken(deviceBinding.product));
    }

    function run() public view {
        bool accessible = accessToken.isUserOwned(vm.addr(deployerPrivateKey), deviceBinding.tokenId);
        console.log("accessible:", accessible);
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
