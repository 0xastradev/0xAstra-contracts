// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import {VizingOmni} from "@vizing/contracts/VizingOmni.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";


contract AstraIntelCollect is Ownable,VizingOmni {
    struct CollectData {
        uint256 latestCollectTime;
        uint256 boostCount;
        uint256 consecutiveDays;
    }
    mapping(address => CollectData) private users;

    event IntelCollect(address indexed sender, uint256 boostCount, uint256 consecutiveDays, uint256 latestCollectTime);

    uint32 private constant COLLECT_INTERVAL = 24 * 60 * 60;
    uint64 private WHITE_LIST_CHAIN_ID;
    uint256 private WHITE_LIST_ADDRESS;

    uint256 public participantCount;

    constructor(address _vizingPad,uint64 _chainId, address _whitelistAddr) Ownable(msg.sender) VizingOmni(_vizingPad) {
      WHITE_LIST_ADDRESS = uint256(uint160(_whitelistAddr));
      WHITE_LIST_CHAIN_ID = _chainId;
    }

    function setWhitelist(uint64 _chainId, address _addr) public onlyOwner {
      WHITE_LIST_ADDRESS = uint256(uint160(_addr));
      WHITE_LIST_CHAIN_ID = _chainId;
    }

    function _receiveMessage(
      	uint64 srcChainId,
	      uint256 srcContract,
	      bytes calldata message
    ) internal virtual override {
      require(srcChainId == WHITE_LIST_CHAIN_ID, 'Astra: vizing chainId mismatch');
      require(srcContract == WHITE_LIST_ADDRESS, 'Astra: whitelist contract mismatch');
      
      (bytes memory encodedAddress) = abi.decode(message, (bytes));
      address addr = address(bytes20(encodedAddress));
      
      _collect(addr);
    }

    function _collect(address _msgSender) internal returns (uint256 latestCollectTime, uint256 collectCount, uint256 consecutiveDays) {
        address currentUser = _msgSender;
        CollectData storage user = users[currentUser];

        require(
            user.latestCollectTime == 0 || block.timestamp >= user.latestCollectTime + COLLECT_INTERVAL,
            "Astra: Intel can only be collected once every 24 hours."
        );

        if (user.boostCount == 0) {
            participantCount++;
        }

        // Calculate consecutive days
        if (block.timestamp < user.latestCollectTime + 2 * COLLECT_INTERVAL) {
            user.consecutiveDays++;
        } else {
            user.consecutiveDays = 1;
        }
        user.latestCollectTime = block.timestamp;
        user.boostCount++;

        emit IntelCollect(currentUser, user.boostCount, user.consecutiveDays, block.timestamp);

        return (user.latestCollectTime, user.boostCount, user.consecutiveDays);
    }

    function getUserInfo(
        address userAddress
    ) public view returns (uint256 latestBoostTime, uint256 boostCount, uint256 consecutiveDays) {
        CollectData storage user = users[userAddress];
        return (user.latestCollectTime, user.boostCount, user.consecutiveDays);
    }
}