// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IMarketplaceStructs {
    // Statuses of a listing. WithdrawnOrNotExist, which is 0, is effectively the same as never listed before.
    enum ListingStatus {
        WithdrawnOrNotExist,
        Listing,
        Delisted
    }

    // Statuses of a rental. EndedOrNotExist, which is 0, is effectively the same as never exist before.
    enum RentalStatus {
        EndedOrNotExist,
        Renting
    }

    struct ListingInfo {
        address owner;
        uint256 minRentalDays;
        uint256 maxRentalDays;
        address rentCurrency;
        uint256 dailyRent;
        address payable rentRecipient;
        ListingStatus status;
    }

    struct RentalInfo {
        uint256 startTime;
        uint256 endTime;
        uint256 rentalDays;
        address rentCurrency;
        uint256 dailyRent;
        uint256 totalPaidRent;
        RentalStatus status;
    }

    struct ListArgs {
        address product;
        uint256 tokenId;
        uint256 minRentalDays;
        uint256 maxRentalDays;
        address rentCurrency;
        uint256 dailyRent;
        address rentRecipient;
    }

    struct DelistArgs {
        address payable accessToken;
        uint256 tokenId;
    }

    struct RelistArgs {
        address accessToken;
        uint256 tokenId;
        uint256 minRentalDays;
        uint256 maxRentalDays;
        address rentCurrency;
        uint256 dailyRent;
        address payable rentRecipient;
    }

    struct RentArgs {
        address accessToken;
        uint256 tokenId;
        address tenant;
        uint256 rentalDays;
        uint256 prepaidRent;
    }

    struct PayRentArgs {
        address accessToken;
        uint256 tokenId;
        address tenant;
        uint256 rent;
    }

    struct EndLeaseArgs {
        address accessToken;
        uint256 tokenId;
        address tenant;
    }

    struct WithdrawArgs {
        address accessToken;
        uint256 tokenId;
    }
}