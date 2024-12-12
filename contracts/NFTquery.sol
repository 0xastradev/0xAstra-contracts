// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract TokenQuery {
    function getTokenIds(address nftCollection, address owner) external view returns (uint256[] memory) {
        IERC721 nft = IERC721(nftCollection);

        uint256 maxSupply = 800;
        uint256[] memory ownedTokenIds = new uint256[](maxSupply);
        uint256 ownedTokenCount = 0;

        for (uint256 tokenId = 0; tokenId < maxSupply; tokenId++) {
            try nft.ownerOf(tokenId) returns (address tokenOwner) {
                if (tokenOwner == owner) {
                    ownedTokenIds[ownedTokenCount] = tokenId;
                    ownedTokenCount++;
                }
            } catch {
                continue;
            }
        }

        uint256[] memory result = new uint256[](ownedTokenCount);
        for (uint256 i = 0; i < ownedTokenCount; i++) {
            result[i] = ownedTokenIds[i];
        }

        return result;
    }
}
