// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {PositionInfo} from '../domain/PositionInfo.sol';
import {FixedPointsLib} from './FixedPointsLib.sol';


library PositionValueLib {

    using FixedPointsLib for int256;
    using FixedPointsLib for uint256;
    
    function calculatePositionValue(
        PositionInfo memory positionInfo,
        uint256 currentIndex
    )
        internal 
        pure
        returns(uint256)
    {
        int256 valueOfChange = calculatePositionValueChange(
            int256(positionInfo.indexAtCreation),
            int256(currentIndex),
            int256(positionInfo.amount),
            int8(positionInfo.leverage)
        );
        if (positionInfo.isLong == false) {
            valueOfChange = -valueOfChange;
        }
        
        int256 currentValue = max((int256(positionInfo.amount)+valueOfChange), 0);
        return uint256(currentValue);
    }

    function calculatePositionValueChange(
        int256 indexAtCreation,
        int256 currentIndex,
        int256 amount,
        int8 leverage
    )
        internal
        pure
        returns(int256)
    {
        
        return (currentIndex - indexAtCreation)
            .halfWadDiv(indexAtCreation)
            .halfWadMul(amount)
            *leverage;
    }

    function max(int256 a, int256 b) 
        internal
        pure
        returns(int256)
    {
        if (a >= b) {
            return a;
        } else {
            return b;
        }
    }

}