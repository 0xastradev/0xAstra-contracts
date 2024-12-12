// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract AstraRewards is Ownable, ReentrancyGuard {
    event Claim(
        uint256 indexed value,
        address indexed winner
    );

    struct Card {
        uint256 value;
        uint64 expiredTimestamp;
        uint64 flag;
    }

    using MessageHashUtils for bytes32;
    using ECDSA for bytes32;
    using SafeERC20 for IERC20;

    address private _rewardToken;

    mapping(address => bool) private _signers;

    mapping(address => bool) private _claimedAddress;

    constructor(
        address owner_,
        address[] memory signers_,
        address rewardToken_
    ) Ownable(owner_) {
        require(owner_ != address(0), "Astra: owner is zero");
        require(rewardToken_ != address(0), "Astra: reward token empty");

        _rewardToken = rewardToken_;
        for (uint256 i = 0; i < signers_.length; i++) {
            require(signers_[i] != address(0), "Astra: no signer");
            _signers[signers_[i]] = true;
        }
    }

    function claim(
        Card calldata card,
        bytes calldata sign
    ) external nonReentrant {
        uint256 totalValue = 0;
            require(_claimedAddress[msg.sender] == false, "Astra: already claimed");
            _claimedAddress[msg.sender] = true;
            require(
                card.expiredTimestamp >= block.timestamp,
                "Astra: expired"
            );
            require(
                _signatureVerify(_encodeCard(msg.sender, card), sign),
                "Astra: signature error"
            );

            totalValue += card.value;
            emit Claim(card.value, msg.sender);

        if (card.value > 0) {
            IERC20(_rewardToken).safeTransfer(msg.sender, card.value);
        }
    }

    function _signatureVerify(
        bytes32 _hash,
        bytes memory _signature
    ) internal view returns (bool) {
        return
            _signers[
                address(
                    uint160(_hash.toEthSignedMessageHash().recover(_signature))
                )
            ];
    }

    function encodeCard(
        address winner,
        Card calldata card
    ) public view returns (bytes32 data) {
        data = _encodeCard(winner, card);
    }

    function _encodeCard(
        address winner,
        Card memory card
    ) internal view returns (bytes32 data) {
        data = keccak256(
            abi.encode(
                winner,
                card.value,
                card.expiredTimestamp,
                card.flag
            )
        );
    }

    function setRewardToken(address token) external onlyOwner {
        require(token != address(0), "Astra: reward token is zero");
        _rewardToken = token;
    }

    function setSigners(
        address[] calldata signers,
        bool[] calldata status
    ) external onlyOwner {
        for (uint256 i = 0; i < signers.length; i++) {
            _signers[signers[i]] = status[i];
        }
    }

    function withdraw(address token, uint256 amount) external onlyOwner {
        IERC20(token).safeTransfer(msg.sender, amount);
    }

    function astra() external pure returns (string memory) {
        return "Per aspera ad astra";
    }

    receive() external payable {
        (bool sent, ) = payable(owner()).call{value: msg.value}("");
        (sent);
    }
}
