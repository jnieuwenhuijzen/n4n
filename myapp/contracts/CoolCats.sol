// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract CoolCats is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    mapping (string => bool) existingURIs;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("CoolCats", "CCT") {}

    function isContentOwned(string memory uri) public view returns (bool) {
        return existingURIs[uri] == true;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://<YOUR_JSON_DIRECTORY_CID_FROM_PINATA>/";
    }

    function payToMint(address to, string memory uri) public payable {
        require(!existingURIs[uri], 'NFT already minted!');
        require (msg.value >= 0.05 ether, 'Need to pay up!');
        existingURIs[uri] = true;

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _mint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function count() public view returns (uint256) {
        return _tokenIdCounter.current();
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
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
}
