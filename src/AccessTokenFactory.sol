// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IProduct} from "./interfaces/IProduct.sol";
import {AccessToken} from "./AccessToken.sol";

contract AccessTokenFactory {
    mapping(address => address) public getAccessToken;

    function createAccessToken(
        address productAddress
    ) external returns (address) {
        require(
            address(getAccessToken[productAddress]) == address(0),
            "existing access token"
        );

        AccessToken accessToken = new AccessToken(
            IProduct(productAddress),
            ERC721(productAddress).name(),
            ERC721(productAddress).symbol()
        );
        getAccessToken[productAddress] = address(accessToken);
        return address(accessToken);
    }
}
