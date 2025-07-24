// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IReserveManager {

    function transferToUser(
        address _to,
        uint256 _amount
    ) 
        external;
}