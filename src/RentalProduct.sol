// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IProduct} from "./interfaces/IProduct.sol";

contract RentalProduct {
    IProduct public immutable PRODUCT;

    mapping(uint256 => address) public getUserByTokenId;

    constructor(IProduct product) {
        PRODUCT = product;
    }

    modifier onlyTokenOwner(uint256 tokenId) {
        require(
            msg.sender == PRODUCT.ownerOf(tokenId),
            "not token owner"
        );
        _;
    }

    function addUser(
        uint256 tokenId,
        address user
    ) external onlyTokenOwner(tokenId) {
        getUserByTokenId[tokenId] = user;
    }

    function revokeUser(uint256 tokenId) external onlyTokenOwner(tokenId) {
        getUserByTokenId[tokenId] = address(0);
    }

    function isUser(uint256 tokenId, address user) public view returns (bool) {
        return getUserByTokenId[tokenId] == user;
    }

    function _fallback(address logic) internal {
        assembly {
            let ptr := mload(0x40)

            // (1) copy incoming call data
            calldatacopy(ptr, 0, calldatasize())

            // (2) forward call to logic contract
            let result := call(
                gas(),
                logic,
                callvalue(),
                ptr,
                calldatasize(),
                0,
                0
            )
            let size := returndatasize()

            // (3) retrieve return data
            returndatacopy(ptr, 0, size)

            // (4) forward return data back to caller
            switch result
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
            }
        }
    }

    fallback() external payable {
        _fallback(address(PRODUCT));
    }

    receive() external payable {}
}
