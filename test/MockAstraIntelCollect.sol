// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "lib/forge-std/src/Test.sol";

contract MockAstraIntelCollect is Test  {

    function receiveMessage(
        bytes memory message
    ) public pure returns (address) {
        console.logBytes(message);
        console.log(message.length,'message.length');
        (bytes memory encodedAddress) = abi.decode(message, (bytes));
        console.log(encodedAddress.length,'encodedAddress.length');
        console.logBytes(encodedAddress);
        address addr = address(bytes20(encodedAddress));
        console.log(addr);
        return addr;
    }

   function testDecodeAddress() public pure {
        // 创建一个已知的地址
        bytes memory encodedAddress = hex"00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000014e1849e61296626cd8e3717082f1b940e2a7dbc52000000000000000000000000";
        address addrs = receiveMessage(encodedAddress);
        console.log(addrs);
    }

}