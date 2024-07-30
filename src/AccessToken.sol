// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IProduct} from "./interfaces/IProduct.sol";

contract AccessToken is ERC721 {
    IProduct public immutable PRODUCT;

    constructor(
        IProduct product,
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) {
        PRODUCT = product;
    }

    modifier onlyTokenOwner(uint256 tokenId) {
        require(msg.sender == PRODUCT.ownerOf(tokenId), "not token owner");
        _;
    }

    function mint(
        address user,
        uint256 tokenId
    ) external onlyTokenOwner(tokenId) {
        _mint(user, tokenId);
    }

    function burn(uint256 tokenId) external onlyTokenOwner(tokenId) {
        _burn(tokenId);
    }
}
