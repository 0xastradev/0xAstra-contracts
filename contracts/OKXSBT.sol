// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract OKXSBT is ERC1155, Ownable {
  using Strings for uint256;
  bool private isLocked;
  mapping(address => bool) public _minted;
  bytes32 public merkleRoot;
  string public _tokenURI = "";

  error ErrLocked();
  error ErrNotFound();

  function uri(uint256 tokenId) public view override returns (string memory) {
    return _tokenURI;
  }

  function setTokenURI(string memory tokenURI_) public onlyOwner {
    _tokenURI = tokenURI_;
  }


  constructor(bytes32 _merkleRoot, string memory tokenURI_)
  ERC1155(tokenURI_) Ownable(msg.sender)
  {
    isLocked = true;
    merkleRoot = _merkleRoot;
    _tokenURI = tokenURI_;
  }

  function setLock(bool _isLocked) public onlyOwner {
    isLocked = _isLocked;
  }

  function locked(uint256 tokenId) public view returns (bool) {
    return isLocked;
  }

  function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
    merkleRoot = _merkleRoot;
  }

  function mintTo(address _to, uint256 _tokenId, uint256 _amount) public onlyOwner {
    _mint(_to, _tokenId, _amount, "");
  }

  function whitelistMint(uint256 _starValue, bytes32[] calldata _merkleProof) public {
    require(!_minted[msg.sender], "0xAstra: Already minted");
    bytes32 leaf = keccak256(abi.encodePacked(msg.sender, _starValue));
    require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), "0xAstra: Invalid merkle proof");
    _mint(msg.sender, 1, _starValue, "");
    _minted[msg.sender] = true;
  }

  modifier checkLock() {
    if (isLocked) revert ErrLocked();
    _;
  }

  function setApprovalForAll(address operator, bool approved)
    public
    override
    checkLock
  {
    super.setApprovalForAll(operator, approved);
  }

  function safeTransferFrom(
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) public virtual override checkLock {
    super.safeTransferFrom(from, to, id, amount, data);
  }

  function safeBatchTransferFrom(
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) public virtual override checkLock {
    super.safeBatchTransferFrom(from, to, ids, amounts, data);
  }
}