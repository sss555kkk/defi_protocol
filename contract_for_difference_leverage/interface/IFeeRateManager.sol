// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;


interface IFeeRateManager {
    function feeRate() external view returns(uint256);
}

