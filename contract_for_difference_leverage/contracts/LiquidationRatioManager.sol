

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ILiquidationRatioManager} from '../interface/ILiquidationRatioManager.sol';

contract LiquidationRatioManager is ILiquidationRatioManager {

    uint256 private _liquidationRatio;

    constructor(uint256 initialRatio) {
        _liquidationRatio = initialRatio;
    }

    function liquidationRatio()
        external
        view
        returns(uint256)
    {
        return _liquidationRatio;
    }
}








