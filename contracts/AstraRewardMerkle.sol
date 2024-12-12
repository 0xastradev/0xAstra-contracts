// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract AstraRewardsMerkle is Ownable, ReentrancyGuard {
    event Claim(
        uint256 indexed value,
        address indexed winner
    );

    using SafeERC20 for IERC20;
    mapping(address => bool) public _claimedAddress;

    bytes32 public whitelistRoot;
    address public rewardToken;

    constructor(
        address owner_,
        bytes32 _whitelistRoot,
        address _rewardToken
    ) Ownable(owner_) {
        require(owner_ != address(0), "Astra: owner is zero");
        whitelistRoot = _whitelistRoot; 
        rewardToken = _rewardToken;
    }

    function claim(
        uint256 amount,
        bytes32[] calldata _proof
    ) external nonReentrant {
            require(_claimedAddress[msg.sender] == false, "Astra: already claimed");
            bytes32 leaf = keccak256(abi.encodePacked(msg.sender, amount));
            require(MerkleProof.verify(_proof, whitelistRoot, leaf), "Invalid proof");
            _claimedAddress[msg.sender] = true;
            emit Claim(amount, msg.sender);
        if (amount > 0) {
            IERC20(rewardToken).safeTransfer(msg.sender, amount);
        }
    }

    function setMerkleRoot(
        bytes32 _whitelistRoot
    ) external onlyOwner {
      whitelistRoot = _whitelistRoot;
    }

    function setRewardToken(address token) external onlyOwner {
        require(token != address(0), "Astra: reward token is zero");
        rewardToken = token;
    }

    function withdraw(address token, uint256 amount) external onlyOwner {
        IERC20(token).safeTransfer(msg.sender, amount);
    }

    function withdraw(uint256 amount) external onlyOwner {
        (bool sent, ) = payable(owner()).call{value: amount}("");
        (sent);
    }

    function astra() external pure returns (string memory) {
        return "Per aspera ad astra";
    }

    receive() external payable {
    }
}
