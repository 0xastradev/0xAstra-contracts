pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract AstraChargeCard is ERC1155, Ownable {
    using MessageHashUtils for bytes32;
    using ECDSA for bytes32;
    using Strings for uint256;

    address private signer;

    mapping(string => bool) private usedCodes;
    string private _uri;

    constructor(string memory uri_, address _owner, address _signer) Ownable(_owner) ERC1155(uri_) {
        signer = _signer;
        _uri = uri_;
    }

    function setURI(string memory uri_) external onlyOwner {
        _uri = uri_;
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        return string(abi.encodePacked(_uri, tokenId.toString(), ".json"));
    }

    function setSigner(address _signer) external onlyOwner {
        signer = _signer;
    }

    function mintNFT(
        address to,
        uint256 id,
        string memory code,
        bytes memory signature
    ) external {
        require(!usedCodes[code], "Astra: Code has already been used");

        bytes32 messageHash = keccak256(abi.encodePacked(to, code, id));
        bytes32 ethSignedMessageHash = messageHash.toEthSignedMessageHash();

        address _signer = ethSignedMessageHash.recover(signature);
        require(_signer == signer, "Astra: Invalid signature");

        usedCodes[code] = true;

        _mint(to, id, 1, "");
    }
}
