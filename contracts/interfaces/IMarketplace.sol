// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IMarketplaceStructs} from "./IMarketplaceStructs.sol";
import {IMarketplaceEvents} from "./IMarketplaceEvents.sol";

interface IMarketplace is IMarketplaceStructs, IMarketplaceEvents {
    function getListingInfo(
        address accessToken,
        uint256 tokenId
    ) external view returns (ListingInfo memory);

    function getRentalInfo(
        address accessToken,
        uint256 tokenId,
        address tenant
    ) external view returns (RentalInfo memory);

    function setFeePoints(uint256 feePoints) external;

    function setTreasury(address payable treasury) external;

    function addRentCurrencies(address[] memory rentCurrencies) external;

    function removeRentCurrencies(address[] memory rentCurrencies) external;

    function list(ListArgs memory args) external;

    function delist(DelistArgs memory args) external;

    function relist(RelistArgs memory args) external;

    function rent(RentArgs memory args) external payable;

    function payRent(PayRentArgs memory args) external payable;

    function endLease(EndLeaseArgs memory args) external;

    function withdraw(WithdrawArgs memory args) external;
}
