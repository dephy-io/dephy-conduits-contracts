// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {AccessTokenFactory} from "../contracts/AccessTokenFactory.sol";
import {AccessToken} from "../contracts/AccessToken.sol";
import {IProduct} from "../contracts/interfaces/IProduct.sol";
import {MockProduct} from "./mocks/MockProduct.sol";
import "forge-std/src/Test.sol";

contract AccessTokenFactoryTest is Test {
    AccessTokenFactory factory;
    MockProduct product;

    function setUp() public {
        factory = new AccessTokenFactory();
        MockProduct productImpl = new MockProduct();
        product = MockProduct(Clones.clone(address(productImpl)));
        product.initialize("MockProduct", "MP", "https://examples.com");
    }

    function testCreateAccessToken() public {
        address productAddress = address(product);

        assertEq(factory.getAccessToken(productAddress), address(0));

        address accessTokenAddress = factory.createAccessToken(productAddress);
        assertTrue(accessTokenAddress != address(0));
        assertEq(factory.getAccessToken(productAddress), accessTokenAddress);

        AccessToken accessToken = AccessToken(accessTokenAddress);
        assertEq(accessToken.name(), "MockProduct");
        assertEq(accessToken.symbol(), "AC.MP");
    }

    function testCreateAccessTokenTwice() public {
        address productAddress = address(product);
        factory.createAccessToken(productAddress);

        vm.expectRevert("existing access token");
        factory.createAccessToken(productAddress);
    }
}