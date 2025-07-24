// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IFeeRateManager} from '../interface/IFeeRateManager.sol';

contract FeeRateManager is IFeeRateManager {
    
    uint256 private _feeRate;

    constructor(uint256 initialFeeRate) {
        _feeRate = initialFeeRate;
    }

    function feeRate() 
        external 
        view
        returns(uint256) 
    {
        return _feeRate;
    }
}










