// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract veSTAR {
    IERC20 public starToken;

    uint256 public constant MAX_LOCK_TIME = 4 * 365 * 86400;

    struct LockInfo {
        uint256 amount;
        uint256 unlockTime;
    }

    mapping(address => LockInfo[]) public locked;

    event Locked(address indexed user, uint256 amount, uint256 unlockTime);
    event Withdrawn(address indexed user, uint256 amount);

    constructor(address _starToken) {
        starToken = IERC20(_starToken);
    }

    function lock(uint256 amount, uint256 time) external {
        require(time > 0 && time <= MAX_LOCK_TIME, "Invalid lock time");
        require(amount > 0, "Cannot lock 0 tokens");

        starToken.transferFrom(msg.sender, address(this), amount);

        uint256 unlockTime = block.timestamp + time;

        // Create a new lock entry
        LockInfo memory newLock = LockInfo({
            amount: amount,
            unlockTime: unlockTime
        });

        // Add the new lock to the user's locks array
        locked[msg.sender].push(newLock);

        emit Locked(msg.sender, amount, unlockTime);
    }

    function calculateveSTAR(address user) public view returns (uint256) {
        LockInfo[] memory lockData = locked[user];
        if (block.timestamp >= lockData[lockData.length - 1].unlockTime) {
            return 0; 
        }
        uint256 lockDuration = lockData[lockData.length - 1].unlockTime - block.timestamp;
        return (lockData[lockData.length - 1].amount * lockDuration) / MAX_LOCK_TIME;
    }

    function withdraw() external {
        LockInfo[] storage userLocks = locked[msg.sender];
        require(userLocks.length > 0, "No locked tokens");

        uint256 totalAmount = 0;
        uint256 currentTime = block.timestamp;

        for (uint256 i = 0; i < userLocks.length; i++) {
            if (currentTime >= userLocks[i].unlockTime) {
                totalAmount += userLocks[i].amount;
                userLocks[i] = userLocks[userLocks.length - 1];
                userLocks.pop();
                i--;
            }
        }

        require(totalAmount > 0, "No tokens available for withdrawal");

        starToken.transfer(msg.sender, totalAmount);

        emit Withdrawn(msg.sender, totalAmount);
    }

    function getVotingPower(address user) external view returns (uint256) {
        return calculateveSTAR(user); 
    }
}
