// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IMarketplaceEvents {
    event List(
        address indexed owner,
        address indexed product,
        address accessToken,
        uint256 indexed tokenId,
        uint256 minRentalDays,
        uint256 maxRentalDays,
        address rentCurrency,
        uint256 dailyRent,
        address rentRecipient
    );

    event Delist(
        address indexed owner,
        address indexed accessToken,
        uint256 indexed tokenId
    );

    event Relist(
        address indexed owner,
        address indexed accessToken,
        uint256 indexed tokenId,
        uint256 minRentalDays,
        uint256 maxRentalDays,
        address rentCurrency,
        uint256 dailyRent,
        address rentRecipient
    );

    event Rent(
        address indexed tenant,
        address indexed accessToken,
        uint256 indexed tokenId,
        uint256 rentalDays,
        uint256 prepaidRent
    );

    event PayRent(
        address indexed tenant,
        address indexed accessToken,
        uint256 indexed tokenId,
        uint256 rent
    );

    event EndLease(
        address indexed tenant,
        address indexed accessToken,
        uint256 indexed tokenId,
        address operator
    );

    event Withdraw(
        address indexed owner,
        address indexed accessToken,
        uint256 indexed tokenId
    );
}