// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {FixedPointsLib} from './FixedPointsLib.sol';


library CalculationLib {
    
    using FixedPointsLib for uint256;

    function calculatePropotion(
        uint256 numerator,
        uint256 denominator,
        uint256 targetBase
    )
        external
        pure
        returns(uint256)
    {
        uint256 targetValue 
            = numerator.halfWadMul(targetBase).halfWadDiv(denominator);
        return targetValue;
    }

    function calculateValueAfterFee(
        uint256 valueBeforeFee,
        uint256 feeRate
    )
        internal
        pure
        returns(uint256)
    {
        uint256 valueAfterFee = valueBeforeFee.halfWadMul(
            FixedPointsLib.halfWAD - 
            feeRate
        );
        return valueAfterFee;
    }
}