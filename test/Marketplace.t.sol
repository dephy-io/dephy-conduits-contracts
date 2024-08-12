// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {AccessTokenFactory} from "../contracts/AccessTokenFactory.sol";
import {IMarketplaceStructs} from "../contracts/interfaces/IMarketplaceStructs.sol";
import {Marketplace} from "../contracts/Marketplace.sol";
import {AccessToken} from "../contracts/AccessToken.sol";
import {IProduct} from "../contracts/interfaces/IProduct.sol";
import {MockProduct} from "./mocks/MockProduct.sol";
import "forge-std/src/Test.sol";

contract AccessTokenFactoryTest is Test {
    AccessTokenFactory factory;
    MockProduct product;
    Marketplace marketplace;

    address treasury;
    uint256 feePoints = 100;

    function setUp() public {
        treasury = makeAddr("treasury");

        factory = new AccessTokenFactory();
        MockProduct productImpl = new MockProduct();
        product = MockProduct(Clones.clone(address(productImpl)));
        product.initialize("MockProduct", "MP", "https://examples.com");

        marketplace = new Marketplace(
            address(this),
            address(factory),
            new address[](0),
            payable(treasury),
            feePoints
        );
    }

    function testList() public {
        address productAddress = address(product);

        // Mint the product token to this contract
        uint256 tokenId = product.mint(address(this));

        // List the product token on the marketplace
        IMarketplaceStructs.ListArgs memory args = IMarketplaceStructs.ListArgs({
            product: productAddress,
            tokenId: tokenId,
            minRentalDays: 1,
            maxRentalDays: 30,
            rentCurrency: address(0),
            dailyRent: 1 ether,
            rentRecipient: payable(address(this))
        });

        product.approve(address(marketplace), tokenId);
        marketplace.list(args);

        // Check that the token is listed
        IMarketplaceStructs.ListingInfo memory listing = marketplace.getListingInfo(
            address(factory.getAccessToken(productAddress)),
            tokenId
        );
        assertEq(listing.owner, address(this));
        assertEq(listing.minRentalDays, 1);
        assertEq(listing.maxRentalDays, 30);
        assertEq(listing.rentCurrency, address(0));
        assertEq(listing.dailyRent, 1 ether);
        assertEq(
            uint256(listing.status),
            uint256(IMarketplaceStructs.ListingStatus.Listing)
        );
    }

    function testDelist() public {
        address productAddress = address(product);
        uint256 tokenId = product.mint(address(this));

        // List the product token on the marketplace
        IMarketplaceStructs.ListArgs memory listArgs = IMarketplaceStructs.ListArgs({
            product: productAddress,
            tokenId: tokenId,
            minRentalDays: 1,
            maxRentalDays: 30,
            rentCurrency: address(0),
            dailyRent: 1 ether,
            rentRecipient: payable(address(this))
        });

        product.approve(address(marketplace), tokenId);
        marketplace.list(listArgs);

        // Delist the token
        IMarketplaceStructs.DelistArgs memory delistArgs = IMarketplaceStructs.DelistArgs({
            accessToken: payable(factory.getAccessToken(productAddress)),
            tokenId: tokenId
        });

        marketplace.delist(delistArgs);

        // Check that the token is delisted
        IMarketplaceStructs.ListingInfo memory listing = marketplace.getListingInfo(
            address(factory.getAccessToken(productAddress)),
            tokenId
        );
        assertEq(
            uint256(listing.status),
            uint256(IMarketplaceStructs.ListingStatus.Delisted)
        );

        address tenant = makeAddr("tenant");
        vm.deal(tenant, 10 ether);
        IMarketplaceStructs.RentArgs memory rentArgs = IMarketplaceStructs.RentArgs({
            accessToken: factory.getAccessToken(productAddress),
            tokenId: tokenId,
            tenant: tenant,
            rentalDays: 5,
            prepaidRent: 5 ether
        });

        vm.prank(tenant);
        vm.expectRevert("not listing");
        marketplace.rent{value: 5 ether}(rentArgs);
    }

    function testRent() public {
        address productAddress = address(product);
        uint256 tokenId = product.mint(address(this));

        address tenant = makeAddr("tenant");
        vm.deal(tenant, 10 ether);

        // List the product token on the marketplace
        IMarketplaceStructs.ListArgs memory listArgs = IMarketplaceStructs.ListArgs({
            product: productAddress,
            tokenId: tokenId,
            minRentalDays: 1,
            maxRentalDays: 30,
            rentCurrency: address(0),
            dailyRent: 1 ether,
            rentRecipient: payable(address(this))
        });

        product.approve(address(marketplace), tokenId);
        marketplace.list(listArgs);

        // Rent the token
        IMarketplaceStructs.RentArgs memory rentArgs = IMarketplaceStructs.RentArgs({
            accessToken: factory.getAccessToken(productAddress),
            tokenId: tokenId,
            tenant: tenant,
            rentalDays: 5,
            prepaidRent: 5 ether
        });

        vm.prank(tenant);
        marketplace.rent{value: 5 ether}(rentArgs);

        // Check that the token is rented
        IMarketplaceStructs.RentalInfo memory rental = marketplace.getRentalInfo(
            address(factory.getAccessToken(productAddress)),
            tokenId,
            tenant
        );
        assertEq(rental.startTime, block.timestamp);
        assertEq(rental.endTime, block.timestamp + 5 days);
        assertEq(rental.rentalDays, 5);
        assertEq(rental.dailyRent, 1 ether);
        assertEq(
            uint256(rental.status),
            uint256(IMarketplaceStructs.RentalStatus.Renting)
        );
    }

    function testPayRent() public {
        address productAddress = address(product);
        uint256 tokenId = product.mint(address(this));

        address tenant = makeAddr("tenant");
        vm.deal(tenant, 20 ether);

        // List the product token on the marketplace
        IMarketplaceStructs.ListArgs memory listArgs = IMarketplaceStructs.ListArgs({
            product: productAddress,
            tokenId: tokenId,
            minRentalDays: 1,
            maxRentalDays: 30,
            rentCurrency: address(0),
            dailyRent: 1 ether,
            rentRecipient: payable(address(this))
        });

        product.approve(address(marketplace), tokenId);
        marketplace.list(listArgs);

        // Rent the token
        IMarketplaceStructs.RentArgs memory rentArgs = IMarketplaceStructs.RentArgs({
            accessToken: factory.getAccessToken(productAddress),
            tokenId: tokenId,
            tenant: tenant,
            rentalDays: 8,
            prepaidRent: 5 ether
        });

        vm.prank(tenant);
        marketplace.rent{value: 5 ether}(rentArgs);

        IMarketplaceStructs.RentalInfo memory rental = marketplace.getRentalInfo(
            address(factory.getAccessToken(productAddress)),
            tokenId,
            tenant
        );
        assertEq(rental.startTime, block.timestamp);
        assertEq(rental.endTime, block.timestamp + 8 days); // 5 initial days + 3 additional days
        assertEq(rental.rentalDays, 8);
        assertEq(rental.dailyRent, 1 ether);
        assertEq(rental.totalPaidRent, 5 ether);
        assertEq(
            uint256(rental.status),
            uint256(IMarketplaceStructs.RentalStatus.Renting)
        );

        // Pay additional rent
        IMarketplaceStructs.PayRentArgs memory payRentArgs = IMarketplaceStructs.PayRentArgs({
            accessToken: factory.getAccessToken(productAddress),
            tokenId: tokenId,
            tenant: tenant,
            rent: 3 ether
        });

        vm.prank(tenant);
        marketplace.payRent{value: 3 ether}(payRentArgs);

        // Check that the total paid rent is increment
        rental = marketplace.getRentalInfo(
            address(factory.getAccessToken(productAddress)),
            tokenId,
            tenant
        );
        assertEq(rental.totalPaidRent, 8 ether); 
    }

    function testEndLease() public {
        address productAddress = address(product);
        uint256 tokenId = product.mint(address(this));

        // address receiver = makeAddr("receiver");
        address tenant = makeAddr("tenant");
        vm.deal(tenant, 10 ether);

        // List the product token on the marketplace
        IMarketplaceStructs.ListArgs memory listArgs = IMarketplaceStructs.ListArgs({
            product: productAddress,
            tokenId: tokenId,
            minRentalDays: 1,
            maxRentalDays: 30,
            rentCurrency: address(0),
            dailyRent: 1 ether,
            rentRecipient: payable(address(this))
        });

        product.approve(address(marketplace), tokenId);
        marketplace.list(listArgs);

        // Rent the token
        IMarketplaceStructs.RentArgs memory rentArgs = IMarketplaceStructs.RentArgs({
            accessToken: factory.getAccessToken(productAddress),
            tokenId: tokenId,
            tenant: tenant,
            rentalDays: 5,
            prepaidRent: 5 ether
        });

        vm.prank(tenant);
        marketplace.rent{value: 5 ether}(rentArgs);

        // Advance time to end the rental period
        vm.warp(block.timestamp + 6 days);

        // End the lease
        IMarketplaceStructs.EndLeaseArgs memory endLeaseArgs = IMarketplaceStructs
            .EndLeaseArgs({
                accessToken: factory.getAccessToken(productAddress),
                tokenId: tokenId,
                tenant: tenant
            });

        vm.prank(tenant);
        marketplace.endLease(endLeaseArgs);

        // Check that the lease is ended
        IMarketplaceStructs.RentalInfo memory rental = marketplace.getRentalInfo(
            address(factory.getAccessToken(productAddress)),
            tokenId,
            tenant
        );
        assertEq(
            uint256(rental.status),
            uint256(IMarketplaceStructs.RentalStatus.EndedOrNotExist)
        );
    }

    function testWithdraw() public {
        address productAddress = address(product);
        uint256 tokenId = product.mint(address(this));

        // List the product token on the marketplace
        IMarketplaceStructs.ListArgs memory listArgs = IMarketplaceStructs.ListArgs({
            product: productAddress,
            tokenId: tokenId,
            minRentalDays: 1,
            maxRentalDays: 30,
            rentCurrency: address(0),
            dailyRent: 1 ether,
            rentRecipient: payable(address(this))
        });

        product.approve(address(marketplace), tokenId);
        marketplace.list(listArgs);

        // Delist the token
        IMarketplaceStructs.DelistArgs memory delistArgs = IMarketplaceStructs.DelistArgs({
            accessToken: payable(factory.getAccessToken(productAddress)),
            tokenId: tokenId
        });

        marketplace.delist(delistArgs);

        // Withdraw the token
        IMarketplaceStructs.WithdrawArgs memory withdrawArgs = IMarketplaceStructs
            .WithdrawArgs({
                accessToken: factory.getAccessToken(productAddress),
                tokenId: tokenId
            });

        marketplace.withdraw(withdrawArgs);

        // Check that the token is withdrawn
        IMarketplaceStructs.ListingInfo memory listing = marketplace.getListingInfo(
            address(factory.getAccessToken(productAddress)),
            tokenId
        );
        assertEq(
            uint256(listing.status),
            uint256(IMarketplaceStructs.ListingStatus.WithdrawnOrNotExist)
        );
    }

    receive() external payable {}
}
