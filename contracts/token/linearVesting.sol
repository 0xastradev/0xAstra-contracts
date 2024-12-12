// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LinearVestingToken is Ownable {
    ERC20 public token;
    uint256 public startTime;
    uint256 public unlockDuration = 365 days;
    uint256 public unlockedAmount;

    uint256 public vestedAmount;
    address public vester;

    constructor(address arai, uint256 _startTime, address _vester) Ownable(msg.sender) {
        token = ERC20(arai);
        startTime = _startTime;
        vester = _vester;
    }

    function vestTokens(uint256 amount) external onlyOwner {
        require(amount <= token.balanceOf(address(this)), "Insufficient balance");
        vestedAmount += amount;
        token.transferFrom(msg.sender, address(this), amount);
    }

    function claim() external {
        require(msg.sender == vester, "Only vester can claim");
        require(block.timestamp >= startTime, "Vesting has not started yet");
        uint256 amountToUnlock = _getUnlockableTokens();

        require(amountToUnlock > 0, "No tokens to unlock");
        require(amountToUnlock <= vestedAmount, "Exceeds vested amount");

        unlockedAmount += amountToUnlock;
        token.transfer(msg.sender, amountToUnlock);
    }

    function _getUnlockableTokens() internal view returns (uint256) {
        uint256 totalUnlockable = (vestedAmount * (block.timestamp - startTime)) / (unlockDuration);
        return totalUnlockable - unlockedAmount;
    }

    function getUnlockableTokens() external view returns (uint256) {
        return _getUnlockableTokens();
    }
}