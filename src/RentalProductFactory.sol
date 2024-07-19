// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IProduct} from "./interfaces/IProduct.sol";
import {RentalProduct} from "./RentalProduct.sol";

contract RentalProductFactory {
    mapping (address => address) public getRentalProduct;

    function createRentalProduct(
        address productAddress
    ) external returns (address)
    {
        require(
            address(getRentalProduct[productAddress]) == address(0),
            "existing rental product"
        );

        RentalProduct rentalProduct = new RentalProduct(IProduct(productAddress));
        getRentalProduct[productAddress] = address(rentalProduct);
        return address(rentalProduct);
    }
}