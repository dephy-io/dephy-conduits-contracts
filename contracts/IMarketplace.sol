// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

interface IMarketplace {
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
        uint256 minRentalDays;
        uint256 maxRentalDays;
        address rentCurrency;
        uint256 dailyRent;
        address payable rentRecipient;
        ListingStatus status;
    }

    struct RentalInfo {
        uint256 accessId;
        uint256 startTime;
        uint256 endTime;
        uint256 rentalDays;
        address rentCurrency;
        uint256 dailyRent;
        uint256 totalPaidRent;
        RentalStatus status;
    }

    event List(
        address indexed owner,
        address indexed device,
        uint256 minRentalDays,
        uint256 maxRentalDays,
        address rentCurrency,
        uint256 dailyRent,
        address rentRecipient
    );

    event Delist(address indexed owner, address indexed device);

    event Relist(
        address indexed owner,
        address indexed device,
        uint256 minRentalDays,
        uint256 maxRentalDays,
        address rentCurrency,
        uint256 dailyRent,
        address rentRecipient
    );

    event Rent(
        address indexed device,
        uint256 indexed accessId,
        address indexed tenant,
        uint256 startTime,
        uint256 endTime,
        uint256 rentalDays,
        uint256 prepaidRent
    );

    event PayRent(
        address indexed device,
        uint256 rent
    );

    event EndLease(
        address indexed device,
        address operator
    );

    event Withdraw(address indexed owner, address indexed device);

    function getListingInfo(
        address device
    ) external view returns (ListingInfo memory);

    function getRentalInfo(
        address device
    ) external view returns (RentalInfo memory);

    function setFeePoints(uint256 feePoints) external;

    function setTreasury(address payable treasury) external;

    function addRentCurrencies(address[] memory rentCurrencies) external;

    function removeRentCurrencies(address[] memory rentCurrencies) external;

    function list(
        address device,
        uint256 minRentalDays,
        uint256 maxRentalDays,
        address rentCurrency,
        uint256 dailyRent,
        address rentRecipient,
        string memory accessURI
    ) external;

    function delist(address device) external;

    function relist(
        address device,
        uint256 minRentalDays,
        uint256 maxRentalDays,
        address rentCurrency,
        uint256 dailyRent,
        address rentRecipient
    ) external;

    function rent(
        address device,
        address tenant,
        uint256 rentalDays,
        uint256 prepaidRent
    ) external payable;

    function payRent(
        address device,
        uint256 rent_
    ) external payable;

    function endLease(address device) external;

    function withdraw(address device) external;
}
