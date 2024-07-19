// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {RentalProductFactory} from "./RentalProductFactory.sol";
import {RentalProduct} from "./RentalProduct.sol";
import {IProduct} from "./interfaces/IProduct.sol";

contract Marketplace is Ownable {
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
        address payable rentalProduct;
        uint256 tokenId;
    }

    struct RelistArgs {
        address payable rentalProduct;
        uint256 tokenId;
        uint256 minRentalDays;
        uint256 maxRentalDays;
        address rentCurrency;
        uint256 dailyRent;
        address payable rentRecipient;
    }

    struct RentArgs {
        address payable rentalProduct;
        uint256 tokenId;
        address tenant;
        uint256 rentalDays;
        uint256 prepaidRent;
    }

    struct PayRentArgs {
        address payable rentalProduct;
        uint256 tokenId;
        address tenant;
        uint256 rent;
    }

    struct EndLeaseArgs {
        address payable rentalProduct;
        uint256 tokenId;
        address tenant;
    }

    struct WithdrawArgs {
        address payable rentalProduct;
        uint256 tokenId;
    }

    using SafeERC20 for IERC20;

    address private constant NATIVE_TOKEN = address(1);

    uint256 public constant MAX_POINTS = 10000;

    RentalProductFactory public immutable RENTAL_PRODUCT_FACTORY;

    address payable private _treasury;

    uint256 private _feePoints;

    /**
     * @notice rent currency => is supported
     */
    mapping(address => bool) public supportedRentCurrencies;

    /**
     * @notice rental product => token id => listing info
     */
    mapping(address => mapping(uint256 => ListingInfo)) public listings;

    /**
     * @notice rental product => token id => tenant => rent info
     */
    mapping(address => mapping(uint256 => mapping(address => RentalInfo)))
        public rentals;

    constructor(
        address initialOwner,
        address rentalProductFactory,
        address[] memory rentCurrencies,
        address payable treasury,
        uint256 feePoints
    ) Ownable(initialOwner) {
        RENTAL_PRODUCT_FACTORY = RentalProductFactory(rentalProductFactory);
        for (uint i = 0; i < rentCurrencies.length; i++) {
            supportedRentCurrencies[rentCurrencies[i]] = true;
        }
        _treasury = treasury;
        _feePoints = feePoints;
    }

    function setFeePoints(uint256 feePoints) external onlyOwner {
        _feePoints = feePoints;
    }

    function setTreasury(address payable treasury) external onlyOwner {
        _treasury = treasury;
    }

    function addRentCurrencies(
        address[] memory rentCurrencies
    ) external onlyOwner {
        for (uint i = 0; i < rentCurrencies.length; i++) {
            supportedRentCurrencies[rentCurrencies[i]] = true;
        }
    }

    function removeRentCurrencies(
        address[] memory rentCurrencies
    ) external onlyOwner {
        for (uint i = 0; i < rentCurrencies.length; i++) {
            supportedRentCurrencies[rentCurrencies[i]] = false;
        }
    }

    function list(ListArgs memory args) public {
        address rentalProduct = RENTAL_PRODUCT_FACTORY.getRentalProduct(
            args.product
        );
        require(address(rentalProduct) != address(0), "unsupported nft");
        require(
            listings[rentalProduct][args.tokenId].status ==
                ListingStatus.WithdrawnOrNotExist, // Never listed or withdrawn
            "token already listed"
        );
        require(args.minRentalDays > 0, "invalid minimum rental days");
        require(
            args.maxRentalDays >= args.minRentalDays,
            "invalid maximum rental days"
        );
        require(
            supportedRentCurrencies[args.rentCurrency],
            "unsupported rent currency"
        );

        listings[rentalProduct][args.tokenId] = ListingInfo({
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
    }

    function delist(DelistArgs memory args) public {
        ListingInfo storage listing = listings[args.rentalProduct][
            args.tokenId
        ];
        require(listing.owner == msg.sender, "not listing owner");
        listing.status = ListingStatus.Delisted;
    }

    function relist(RelistArgs memory args) public {
        ListingInfo storage listing = listings[args.rentalProduct][
            args.tokenId
        ];
        require(listing.owner == msg.sender, "not listing owner");
        require(args.minRentalDays > 0, "invalid minimum rental days");
        require(
            args.maxRentalDays >= args.minRentalDays,
            "invalid maximum rental days"
        );
        require(
            supportedRentCurrencies[args.rentCurrency],
            "unsupported rent currency"
        );

        listing.minRentalDays = args.minRentalDays;
        listing.maxRentalDays = args.maxRentalDays;
        listing.rentCurrency = args.rentCurrency;
        listing.dailyRent = args.dailyRent;
        listing.rentRecipient = args.rentRecipient;
        listing.status = ListingStatus.Listing;
    }

    function rent(RentArgs memory args) public payable {
        require(
            rentals[args.rentalProduct][args.tokenId][args.tenant].status ==
                RentalStatus.EndedOrNotExist,
            "existing rental"
        );

        ListingInfo memory listing = listings[args.rentalProduct][args.tokenId];
        require(
            listing.minRentalDays <= args.rentalDays &&
                args.rentalDays <= listing.maxRentalDays,
            "invalid rental days"
        );
        require(
            args.prepaidRent >= listing.minRentalDays * listing.dailyRent,
            "insufficient prepaid rent"
        );

        rentals[args.rentalProduct][args.tokenId][args.tenant] = RentalInfo({
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
            rentals[args.rentalProduct][args.tokenId][args.tenant],
            args.prepaidRent
        );
        // Add the tenant to the rental token
        RentalProduct(payable(args.rentalProduct)).addUser(
            args.tokenId,
            args.tenant
        );
    }

    function payRent(PayRentArgs memory args) public payable {
        ListingInfo memory listing = listings[args.rentalProduct][args.tokenId];
        RentalInfo storage rental = rentals[args.rentalProduct][args.tokenId][
            args.tenant
        ];
        require(
            rental.totalPaidRent + args.rent <=
                rental.rentalDays * rental.dailyRent,
            "too much rent"
        );

        // Pay rent
        _payRent(listing, rental, args.rent);
    }

    function endLease(EndLeaseArgs memory args) public {
        RentalInfo storage rental = rentals[args.rentalProduct][args.tokenId][
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

        // Remove the tenant from the rental product
        RentalProduct(args.rentalProduct).revokeUser(args.tokenId);
        rental.status = RentalStatus.EndedOrNotExist;
    }

    function withdraw(WithdrawArgs memory args) public {
        ListingInfo storage listing = listings[args.rentalProduct][
            args.tokenId
        ];
        require(listing.owner == msg.sender, "not listing owner");
        require(
            RentalProduct(args.rentalProduct).isUser(args.tokenId, address(0)),
            "rental product has user"
        );
        listing.status = ListingStatus.WithdrawnOrNotExist;

        // fallback call: Transfer the nft back to the owner
        IProduct(args.rentalProduct).safeTransferFrom(
            address(this),
            listing.owner,
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
