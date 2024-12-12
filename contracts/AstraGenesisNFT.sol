// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AstraGenesisNFT is ERC721, Ownable {
    uint256 private _tokenIdCounter = 1;
    uint256 public maxSupply;

    bytes32 public whitelistMerkleRoot;
    bytes32 public fcfsMerkleRoot;

    uint8 public mintStatus = 0; 
    string public tokenURI = "";
    mapping(address => bool) public claimed;

    uint256 public whitelistStartTime; 
    uint256 public constant fcfsStartDelay = 6 hours; 

    constructor(
        string memory name,         
        string memory symbol,  
        address _owner,          
        string memory _tokenURI,
        uint256 _maxSupply,       
        bytes32 _whitelistMerkleRoot,  
        bytes32 _fcfsMerkleRoot        
    ) Ownable(_owner) ERC721(name, symbol) {        
        maxSupply = _maxSupply;
        whitelistMerkleRoot = _whitelistMerkleRoot;
        fcfsMerkleRoot = _fcfsMerkleRoot;
        tokenURI = _tokenURI;
    }

    modifier canMint {
        require(_tokenIdCounter <= maxSupply, "Astra: Exceeds maximum supply");
        _;
    }

    function setWhitelistMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        whitelistMerkleRoot = _merkleRoot;
    }

    function setFCFSMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        fcfsMerkleRoot = _merkleRoot;
    }

    function setMintStatus(uint8 _status) external onlyOwner {
        mintStatus = _status;

        if (_status == 1) {
            whitelistStartTime = block.timestamp;
        }
    }

    function setTokenURI(string memory _tokenURI) external onlyOwner {
        tokenURI = _tokenURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return tokenURI;
    }
    
    function getStatus() external view returns (uint8) {
        if (mintStatus == 1 && block.timestamp >= whitelistStartTime + fcfsStartDelay) {
            return 2;
        }
        return mintStatus;
    }

    function whitelistMint(bytes32[] calldata _merkleProof) external canMint {
        require(mintStatus == 1, "Astra: Whitelist phase not open");
        require(!claimed[msg.sender], "Astra: Already minted");
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof, whitelistMerkleRoot, leaf), "Astra: Invalid proof");
        claimed[msg.sender] = true;
        _mintNFT(msg.sender);
    }

    function fcfsMint(bytes32[] calldata _merkleProof) external payable canMint {
        if (mintStatus == 1 && block.timestamp >= whitelistStartTime + fcfsStartDelay) {
            mintStatus = 2; 
        }
        require(mintStatus == 2, "Astra: FCFS phase not open");
        require(!claimed[msg.sender], "Astra: Already minted");
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof, fcfsMerkleRoot, leaf), "Astra: Invalid proof");
        claimed[msg.sender] = true;
        _mintNFT(msg.sender);
    }

    function fcfsOpenCountdown() external view returns (uint256) {
        return whitelistStartTime + fcfsStartDelay - block.timestamp;
    }

    function _mintNFT(address _to) internal {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;
        _safeMint(_to, tokenId);
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    function withdrawERC20(address _token) external onlyOwner {
        IERC20 token = IERC20(_token);
        uint256 balance = token.balanceOf(address(this));
        token.transfer(owner(), balance);
    }

    function withdrawNFT(uint256 _tokenId) external onlyOwner {
        _transfer(address(this), owner(), _tokenId);
    }

    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter - 1; 
    }
}
