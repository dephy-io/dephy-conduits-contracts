// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {AccessToken} from "../src/AccessToken.sol";
import {IProduct} from "../src/interfaces/IProduct.sol";
import {MockProduct} from "./mocks/MockProduct.sol";
import "forge-std/src/Test.sol";

contract AccessTokenTest is Test {
    AccessToken accessToken;
    MockProduct product;

    function setUp() public {
        MockProduct productImpl = new MockProduct();
        product = MockProduct(Clones.clone(address(productImpl)));
        product.initialize("MockProduct", "MP", "https://examples.com");

        accessToken = new AccessToken(
            IProduct(address(product)),
            "AccessToken",
            "AC"
        );
    }

    function testMint() public {
        vm.prank(address(this));
        uint256 tokenId = product.mint(address(this));

        address user = makeAddr("user");
        accessToken.mint(user, tokenId);

        assertEq(accessToken.ownerOf(tokenId), user);
    }

    function testMint_NotProductOwner() public {
        vm.prank(address(this));
        uint256 tokenId = product.mint(address(this));

        address notProductOwner = makeAddr("notProductOwner");
        vm.expectRevert("not product owner");
        vm.prank(notProductOwner);
        accessToken.mint(notProductOwner, tokenId);
    }

    function testBurn() public {
        vm.prank(address(this));
        uint256 tokenId = product.mint(address(this));

        accessToken.mint(address(this), tokenId);
        accessToken.burn(tokenId);

        vm.expectRevert();
        accessToken.ownerOf(tokenId);
    }

    function testBurn_NotProductOwner() public {
        vm.prank(address(this));
        uint256 tokenId = product.mint(address(this));

        accessToken.mint(address(this), tokenId);

        address notProductOwner = makeAddr("notProductOwner");
        vm.prank(notProductOwner);
        vm.expectRevert("not product owner");
        accessToken.burn(tokenId);
    }

    function testMint_AfterBurned() public {
        vm.prank(address(this));
        uint256 tokenId = product.mint(address(this));

        address user1 = makeAddr("user1");
        address user2 = makeAddr("user2");
        accessToken.mint(user1, tokenId);
        accessToken.burn(tokenId);
        accessToken.mint(user2, tokenId);
        assertEq(accessToken.ownerOf(tokenId), user2);
    }
}
