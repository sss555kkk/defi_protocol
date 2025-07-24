// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {PositionValueLib} from '../library/PositionValueLib.sol';
import {PositionInfo} from '../domain/PositionInfo.sol';

contract TestPositionValue {

    using PositionValueLib for PositionInfo;

    function testCalculatePositionValue(
        PositionInfo memory positionInfo,
        uint256 currentIndex
    )
        public
        pure
        returns(uint256, uint256)
    {
        uint256 answer1 = positionInfo.calculatePositionValue(
            currentIndex
        );
        uint256 answer2 = answer1/1e9;
        return (answer1, answer2);
    }
}

