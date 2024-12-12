// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ARAI is ERC20, Ownable {

    uint256 private constant _initialSupply = 1000000000 * 10 ** 18;

    constructor() ERC20("0xAstra", "ARAI") Ownable(msg.sender) {
        _mint(msg.sender, _initialSupply);
    }
}