// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./IArtCollectibleContract.sol";

/// @custom:security-contact dreamsoftware92@gmail.com
contract ArtCollectibleContract is ERC721, ERC721Enumerable, ERC721URIStorage, Pausable, Ownable, ERC721Burnable, IArtCollectibleContract {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    address private _marketPlaceAddress;
    // Mapping to check if the metadata has been minted
    mapping(string => bool) private _hasBeenMinted;
    // Mapping to keep track of the Item
    mapping(uint256 => ArtCollectible) private _tokenIdToItem;
    mapping(string => uint256) private _tokenMetadataCidToTokenId;
    mapping(uint256 => address) private _tokenCreators;
    mapping(address => uint256) private _addressTokensOwned;
    mapping(address => uint256) private _addressTokensCreator;

    constructor() ERC721("ArtCollectibleContract", "ACT") {}


    function setMarketPlaceAddress(address marketPlaceAddress) external onlyOwner() {
        _marketPlaceAddress = marketPlaceAddress;
    }

    /**
     * @dev create an art collectible with a `metadata` for the msg.sender
     *
     * Requirements:
     * - `metadataCid` has not been minted before
     * - `royalty` must be between 0% and 40%
     *
     * Emits a {Transfer} event - comes from the ERC-721 smart contract.
     */
    function mintToken(string memory metadataCid, uint256 royalty) external override whenNotPaused() ItemNotMintedYet(metadataCid) ValidRoyaltyInterval(royalty) returns (uint256) {
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, metadataCid);
        // Give the marketplace approval to transact NFTs between users
        setApprovalForAll(_marketPlaceAddress, true);
        ArtCollectible memory artCollectible = ArtCollectible(tokenId, msg.sender, msg.sender, royalty, metadataCid, true);
        _tokenIdToItem[tokenId] = artCollectible;
        _hasBeenMinted[metadataCid] = true;
        _tokenCreators[tokenId] = msg.sender;
        _tokenMetadataCidToTokenId[metadataCid] = tokenId;
        _addressTokensCreator[msg.sender] += 1;
        _addressTokensOwned[msg.sender] += 1;
        emit ArtCollectibleMinted(tokenId, msg.sender, metadataCid, royalty);
        return tokenId;
    }

    function getTokensCreatedBy(address creatorAddress) external view returns (ArtCollectible[] memory) {
        return _getTokensCreatedBy(creatorAddress, 0);
    }

    function getPaginatedTokensCreatedBy(address creatorAddress, uint256 count) external view returns (ArtCollectible[] memory) {
        return _getTokensCreatedBy(creatorAddress, count);
    }

    function getPaginatedTokensCreatedByMe(uint256 count) external view returns (ArtCollectible[] memory) {
        return _getTokensCreatedBy(msg.sender, count);
    }

    function getTokensCreatedByMe() external view returns (ArtCollectible[] memory) {
        return _getTokensCreatedBy(msg.sender, 0);
    }

    function getPaginatedTokensOwnedBy(address ownedAddress, uint256 count) external view returns (ArtCollectible[] memory) {
        return _getTokensOwnedBy(ownedAddress, count);
    }

    function getTokensOwnedBy(address ownedAddress) external view returns (ArtCollectible[] memory) {
        return _getTokensOwnedBy(ownedAddress, 0);
    }

    function getPaginatedTokensOwnedByMe(uint256 count) external view returns (ArtCollectible[] memory) { 
        return _getTokensOwnedBy(msg.sender, count);
    }

    function getTokensOwnedByMe() external view returns (ArtCollectible[] memory) { 
        return _getTokensOwnedBy(msg.sender, 0);
    }

    function getTokenCreatorById(uint256 tokenId) public view TokenMustExist(tokenId) returns (address) {
        return _tokenCreators[tokenId];
    }

    function getTokens(uint256[] memory tokenIds) external view returns (ArtCollectible[] memory) {
        uint256 tokensAvailables = 0;
        for (uint256 i = 0; i < tokenIds.length; i++) { 
            ArtCollectible memory token = _tokenIdToItem[tokenIds[i]];
            if (!token.isExist) continue;
            tokensAvailables += 1;
        }
        ArtCollectible[] memory tokens = new ArtCollectible[](tokensAvailables);
        uint256 currentIndex = 0;
        for (uint256 i = 0; i < tokensAvailables; i++) { 
            tokens[currentIndex] = _tokenIdToItem[tokenIds[i]];
            currentIndex += 1;
        }
        return tokens;
    }

    function getTokenByMetadataCid(string memory metadataCid) external view ItemMinted(metadataCid) returns (ArtCollectible memory) {
        return _tokenIdToItem[_tokenMetadataCidToTokenId[metadataCid]];
    }


    function getTokensByMetadataCids(string[] memory metadataCids) external view returns (ArtCollectible[] memory) {
        uint256 tokensAvailables = 0;
        for (uint256 i = 0; i < metadataCids.length; i++) { 
            ArtCollectible memory token = _tokenIdToItem[_tokenMetadataCidToTokenId[metadataCids[i]]];
            if (!token.isExist) continue;
            tokensAvailables += 1;
        }
        ArtCollectible[] memory tokens = new ArtCollectible[](tokensAvailables);
        uint256 currentIndex = 0;
        for (uint256 i = 0; i < tokensAvailables; i++) { 
            tokens[currentIndex] = _tokenIdToItem[_tokenMetadataCidToTokenId[metadataCids[i]]];
            currentIndex += 1;
        }
        return tokens;
    }

    function getTokenById(uint256 tokenId) external view TokenMustExist(tokenId) returns (ArtCollectible memory) {
        return _tokenIdToItem[tokenId];
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        _tokenIdToItem[tokenId].isExist = false;
        _addressTokensCreator[msg.sender] -= 1;
        _addressTokensOwned[_tokenCreators[tokenId]] -= 1;
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _getTokensOwnedBy(address ownerAddress, uint256 count) private view returns (ArtCollectible[] memory) { 
        uint256 numberOfExistingTokens = _tokenIdCounter.current();
        uint256 numberOfTokensOwned = balanceOf(ownerAddress);
        uint256 countTokens;
        if(count > numberOfTokensOwned) {
            countTokens = numberOfTokensOwned;
        } else if(count > 0) { 
            countTokens = count;
        } else {
           countTokens = numberOfTokensOwned;
        }
        ArtCollectible[] memory ownedTokens = new ArtCollectible[](countTokens);
        uint256 currentIndex = 0;
        for (uint256 i = 0; i < numberOfExistingTokens && currentIndex < countTokens; i++) {
            uint256 tokenId = i + 1;
            ArtCollectible memory token = _tokenIdToItem[tokenId];
            if (!token.isExist || ownerOf(tokenId) != ownerAddress) continue;
            ownedTokens[currentIndex] = token;
            currentIndex += 1;
        }

        return ownedTokens;
    }

    function _getTokensCreatedBy(address creatorAddress, uint256 count) private view returns (ArtCollectible[] memory) {
        uint256 numberOfExistingTokens = _tokenIdCounter.current();
        uint256 numberOfTokensCreated = 0;
        for (uint256 i = 0; i < numberOfExistingTokens; i++) {
            uint256 tokenId = i + 1;
            if (_tokenCreators[tokenId] != creatorAddress) continue;
            numberOfTokensCreated += 1;
        }
        uint256 countTokens;
        if(count > numberOfTokensCreated) {
            countTokens = numberOfTokensCreated;
        } else if(count > 0) { 
            countTokens = count;
        } else {
           countTokens = numberOfTokensCreated;
        }
        ArtCollectible[] memory createdTokens = new ArtCollectible[](countTokens);
        uint256 currentIndex = 0;
        for (uint256 i = 0; i < numberOfExistingTokens && currentIndex < countTokens; i++) {
            uint256 tokenId = i + 1;
            if (_tokenCreators[tokenId] != creatorAddress) continue;
            createdTokens[currentIndex] = _tokenIdToItem[tokenId];
            currentIndex += 1;
        }

        return createdTokens;
    }

    function transferTo(address from, address to, uint256 tokenId) external{
        transferFrom(from, to, tokenId);
        _tokenIdToItem[tokenId].owner = to;
        _addressTokensOwned[from] -= 1;
        _addressTokensOwned[to] += 1;
    }

    function countTokensOwnedByAddress(address ownerAddress) external view returns (uint256) {
        return _addressTokensOwned[ownerAddress];
    }

    function countTokensCreatorByAddress(address creatorAddress) external view returns (uint256) {
        return _addressTokensCreator[creatorAddress];
    }

    /**
     * @dev Allows you to fetch tokens statistics by address
     */
    function fetchTokensStatisticsByAddress(address targetAddress) external view returns (TokenStatistics memory) {
        uint256 countTokensOwned = this.countTokensOwnedByAddress(targetAddress);
        uint256 countTokensCreator = this.countTokensCreatorByAddress(targetAddress);
        return TokenStatistics(countTokensCreator, countTokensOwned);
    }

    // Modifiers

    modifier ItemNotMintedYet(string memory metadataCid) {
        require(!_hasBeenMinted[metadataCid],"This metadata has already been used to mint an NFT.");
        _;
    }

    modifier ItemMinted(string memory metadataCid) {
        require(_hasBeenMinted[metadataCid],"This metadata has not been used to mint an NFT.");
        _;
    }


    modifier TokenMustExist(uint256 tokenId) {
        require(_tokenIdToItem[tokenId].isExist, "There aren't any token with the token id specified");
        _;
    }

    modifier ValidRoyaltyInterval(uint256 royalty) {
        require(royalty >= 0 && royalty <= 40, "Royalties must be between 0% and 40%.");
        _;
    }
}
