// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface ILiquidationRatioManager {

    function liquidationRatio()
        external
        view
        returns(uint256);
}