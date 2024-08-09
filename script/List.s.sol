// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Marketplace} from "../contracts/Marketplace.sol";
import {IMarketplaceStructs} from "../contracts/interfaces/IMarketplaceStructs.sol";
import {IProduct} from "../contracts/interfaces/IProduct.sol";
import "forge-std/src/Script.sol";

contract List is Script {
    uint256 deployerPrivateKey;
    Marketplace marketplace;
    IProductFactory productFactory;
    address device;
    IProductFactory.DeviceBinding deviceBinding;
    IMarketplaceStructs.ListArgs listArgs;

    function setUp() public {
        deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        marketplace = Marketplace(0x647d77324E241709BaF63D7f96F0C19ecA06E2e0);
        productFactory = IProductFactory(0x8E360F40c7875e096e0DbFe0cC01d1db5aFB78B6);
        device = 0xA7fE098F2D4D2cD6bA158E5470d9231AC223bA06;        // set your device here
        deviceBinding = productFactory.getDeviceBinding(device);
        listArgs = IMarketplaceStructs.ListArgs({
            product: deviceBinding.product,
            tokenId: deviceBinding.tokenId,
            minRentalDays: 5,        // set min rental days
            maxRentalDays: 10,       // set max rental days
            rentCurrency: address(0),     // only whitelisted currency, zero-address means bnb(native token)
            dailyRent: 1e14,        // set daily rent, here is 0.0001 BNB per day
            rentRecipient: vm.addr(deployerPrivateKey)  // set rent receiver
        });
    }

    function run() public {
        vm.startBroadcast(deployerPrivateKey);
        IProduct(deviceBinding.product).approve(address(marketplace), deviceBinding.tokenId);
        marketplace.list(listArgs);
        vm.stopBroadcast();
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
