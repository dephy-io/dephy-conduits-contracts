// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {AccessTokenFactory} from "./AccessTokenFactory.sol";
import {AccessToken} from "./AccessToken.sol";
import {IProduct} from "./interfaces/IProduct.sol";
import {IMarketplace} from "./interfaces/IMarketplace.sol";

contract Marketplace is IMarketplace, Ownable {
    using SafeERC20 for IERC20;

    address public constant NATIVE_TOKEN = address(0);

    uint256 public constant MAX_POINTS = 10000;

    AccessTokenFactory public immutable ACCESS_TOKEN_FACTORY;

    address payable internal _treasury;

    uint256 internal _feePoints;

    /**
     * @notice rent currency => is supported
     */
    mapping(address => bool) public supportedRentCurrencies;

    /**
     * @notice access token => token id => listing info
     */
    mapping(address => mapping(uint256 => ListingInfo)) internal _listings;

    /**
     * @notice access token => token id => tenant => rent info
     */
    mapping(address => mapping(uint256 => mapping(address => RentalInfo)))
        internal _rentals;

    constructor(
        address initialOwner,
        address accessTokenFactory,
        address[] memory rentCurrencies,
        address payable treasury,
        uint256 feePoints
    ) Ownable(initialOwner) {
        ACCESS_TOKEN_FACTORY = AccessTokenFactory(accessTokenFactory);
        for (uint i = 0; i < rentCurrencies.length; i++) {
            supportedRentCurrencies[rentCurrencies[i]] = true;
        }
        _treasury = treasury;
        _feePoints = feePoints;
    }

    /**
     * @inheritdoc IMarketplace
     */
    function getListingInfo(
        address accessToken,
        uint256 tokenId
    ) external view returns (ListingInfo memory) {
        return _listings[accessToken][tokenId];
    }

    /**
     * @inheritdoc IMarketplace
     */
    function getRentalInfo(
        address accessToken,
        uint256 tokenId,
        address tenant
    ) external view returns (RentalInfo memory) {
        return _rentals[accessToken][tokenId][tenant];
    }

    /**
     * @inheritdoc IMarketplace
     */
    function setFeePoints(uint256 feePoints) external onlyOwner {
        _feePoints = feePoints;
    }

    /**
     * @inheritdoc IMarketplace
     */
    function setTreasury(address payable treasury) external onlyOwner {
        _treasury = treasury;
    }

    /**
     * @inheritdoc IMarketplace
     */
    function addRentCurrencies(
        address[] memory rentCurrencies
    ) external onlyOwner {
        for (uint i = 0; i < rentCurrencies.length; i++) {
            supportedRentCurrencies[rentCurrencies[i]] = true;
        }
    }

    /**
     * @inheritdoc IMarketplace
     */
    function removeRentCurrencies(
        address[] memory rentCurrencies
    ) external onlyOwner {
        for (uint i = 0; i < rentCurrencies.length; i++) {
            supportedRentCurrencies[rentCurrencies[i]] = false;
        }
    }

    /**
     * @inheritdoc IMarketplace
     */
    function list(ListArgs memory args) public {
        address accessToken = ACCESS_TOKEN_FACTORY.getAccessToken(args.product);
        if (accessToken == address(0)) {
            accessToken = ACCESS_TOKEN_FACTORY.createAccessToken(args.product);
        }
        require(
            _listings[accessToken][args.tokenId].status ==
                ListingStatus.WithdrawnOrNotExist, // Never listed or withdrawn
            "token already listed"
        );
        require(args.minRentalDays > 0, "invalid minimum rental days");
        require(
            args.maxRentalDays >= args.minRentalDays,
            "invalid maximum rental days"
        );
        require(
            args.rentCurrency == NATIVE_TOKEN ||
                supportedRentCurrencies[args.rentCurrency],
            "unsupported rent currency"
        );

        _listings[accessToken][args.tokenId] = ListingInfo({
            owner: msg.sender,
            minRentalDays: args.minRentalDays,
            maxRentalDays: args.maxRentalDays,
            rentCurrency: args.rentCurrency,
            dailyRent: args.dailyRent,
            rentRecipient: payable(args.rentRecipient),
            status: ListingStatus.Listing
        });

        IProduct(args.product).transferFrom(
            msg.sender,
            address(this),
            args.tokenId
        );

        emit List(
            msg.sender,
            args.product,
            accessToken,
            args.tokenId,
            args.minRentalDays,
            args.maxRentalDays,
            args.rentCurrency,
            args.dailyRent,
            args.rentRecipient
        );
    }

    /**
     * @inheritdoc IMarketplace
     */
    function delist(DelistArgs memory args) public {
        ListingInfo storage listing = _listings[args.accessToken][args.tokenId];
        require(listing.owner == msg.sender, "not listing owner");
        listing.status = ListingStatus.Delisted;

        emit Delist(msg.sender, args.accessToken, args.tokenId);
    }

    /**
     * @inheritdoc IMarketplace
     */
    function relist(RelistArgs memory args) public {
        ListingInfo storage listing = _listings[args.accessToken][args.tokenId];
        require(listing.owner == msg.sender, "not listing owner");
        require(args.minRentalDays > 0, "invalid minimum rental days");
        require(
            args.maxRentalDays >= args.minRentalDays,
            "invalid maximum rental days"
        );
        require(
            args.rentCurrency == NATIVE_TOKEN ||
                supportedRentCurrencies[args.rentCurrency],
            "unsupported rent currency"
        );

        listing.minRentalDays = args.minRentalDays;
        listing.maxRentalDays = args.maxRentalDays;
        listing.rentCurrency = args.rentCurrency;
        listing.dailyRent = args.dailyRent;
        listing.rentRecipient = args.rentRecipient;
        listing.status = ListingStatus.Listing;

        emit Relist(
            msg.sender,
            args.accessToken,
            args.tokenId,
            args.minRentalDays,
            args.maxRentalDays,
            args.rentCurrency,
            args.dailyRent,
            args.rentRecipient
        );
    }

    /**
     * @inheritdoc IMarketplace
     */
    function rent(RentArgs memory args) public payable {
        require(
            _rentals[args.accessToken][args.tokenId][args.tenant].status ==
                RentalStatus.EndedOrNotExist,
            "existing rental"
        );

        ListingInfo memory listing = _listings[args.accessToken][args.tokenId];
        require(
            listing.minRentalDays <= args.rentalDays &&
                args.rentalDays <= listing.maxRentalDays,
            "invalid rental days"
        );
        require(
            args.prepaidRent >= listing.minRentalDays * listing.dailyRent,
            "insufficient prepaid rent"
        );

        _rentals[args.accessToken][args.tokenId][args.tenant] = RentalInfo({
            startTime: block.timestamp,
            endTime: block.timestamp + args.rentalDays * 1 days,
            rentalDays: args.rentalDays,
            rentCurrency: listing.rentCurrency,
            dailyRent: listing.dailyRent,
            totalPaidRent: 0,
            status: RentalStatus.Renting
        });

        // Pay rent
        _payRent(
            listing,
            _rentals[args.accessToken][args.tokenId][args.tenant],
            args.prepaidRent
        );
        // Mint access token to tenant
        AccessToken(args.accessToken).mint(args.tenant, args.tokenId);

        emit Rent(
            args.tenant,
            args.accessToken,
            args.tokenId,
            args.rentalDays,
            args.prepaidRent
        );
    }

    /**
     * @inheritdoc IMarketplace
     */
    function payRent(PayRentArgs memory args) public payable {
        ListingInfo memory listing = _listings[args.accessToken][args.tokenId];
        RentalInfo storage rental = _rentals[args.accessToken][args.tokenId][
            args.tenant
        ];
        require(
            rental.totalPaidRent + args.rent <=
                rental.rentalDays * rental.dailyRent,
            "too much rent"
        );

        // Pay rent
        _payRent(listing, rental, args.rent);

        emit PayRent(
            args.tenant,
            args.accessToken,
            args.tokenId,
            args.rent
        );
    }

    /**
     * @inheritdoc IMarketplace
     */
    function endLease(EndLeaseArgs memory args) public {
        RentalInfo storage rental = _rentals[args.accessToken][args.tokenId][
            args.tenant
        ];
        // The lease can be ended only if the term is over or the rent is insufficient
        uint256 rentNeeded = ((block.timestamp - rental.startTime) *
            rental.dailyRent) / 1 days;
        require(
            rental.endTime < block.timestamp ||
                rental.totalPaidRent < rentNeeded,
            "cannot end lease"
        );

        // Burn tenant's access token
        AccessToken(args.accessToken).burn(args.tokenId);
        rental.status = RentalStatus.EndedOrNotExist;

        emit EndLease(
            args.tenant,
            args.accessToken,
            args.tokenId,
            msg.sender
        );
    }

    /**
     * @inheritdoc IMarketplace
     */
    function withdraw(WithdrawArgs memory args) public {
        ListingInfo storage listing = _listings[args.accessToken][args.tokenId];
        require(listing.owner == msg.sender, "not listing owner");
        require(
            !AccessToken(args.accessToken).isExist(args.tokenId),
            "access token has tenant"
        );
        listing.status = ListingStatus.WithdrawnOrNotExist;

        (AccessToken(args.accessToken).PRODUCT()).transferFrom(
            address(this),
            listing.owner,
            args.tokenId
        );

        emit Withdraw(
            msg.sender,
            args.accessToken,
            args.tokenId
        );
    }

    function _payRent(
        ListingInfo memory listing,
        RentalInfo storage rental,
        uint256 rent_
    ) internal {
        uint256 fee;
        uint256 rentToOwner;

        bool feeOn = _feePoints != 0;
        if (feeOn) {
            fee = (rent_ * _feePoints) / MAX_POINTS;
            rentToOwner = rent_ - fee;
        } else {
            rentToOwner = rent_;
        }

        if (rental.rentCurrency == NATIVE_TOKEN) {
            require(msg.value == rent_, "invalid prepaid rent");
            listing.rentRecipient.transfer(rentToOwner);
            if (feeOn) {
                _treasury.transfer(fee);
            }
        } else {
            IERC20(rental.rentCurrency).safeTransferFrom(
                msg.sender,
                listing.rentRecipient,
                rentToOwner
            );
            if (feeOn) {
                IERC20(rental.rentCurrency).safeTransferFrom(
                    msg.sender,
                    _treasury,
                    fee
                );
            }
        }

        rental.totalPaidRent += rent_;
    }
}
