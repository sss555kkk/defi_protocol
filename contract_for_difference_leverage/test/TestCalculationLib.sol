// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {CalculationLib} from '../library/CalculationLib.sol';
import {FixedPointsLib} from '../library/FixedPointsLib.sol';

contract TestCalculationLib {
    using FixedPointsLib for uint256;

    uint256[] private numerators = [10e9,0, 10e9];
    uint256[] private denominators= [100e9,100e9,100e9];
    uint256[] private targetBases = [1000e9,1000e9,0];

    function testCalculateProportion()
        public
        view
    {
        for (uint8 i=0; i<numerators.length; i++) {
            uint256 expectedValue
                = _getExpectedValueForProportion(numerators[i], denominators[i], targetBases[i]);
            uint256 actualValue
                = _getActualValueForProportion(numerators[i], denominators[i], targetBases[i]);
            assert (expectedValue == actualValue);
        }
    }

    function _getExpectedValueForProportion(
        uint256 numerator,
        uint256 denominator,
        uint256 targetBase

    )
        internal
        pure
        returns(uint256)
    {
        uint256 expectedValue
            = numerator.halfWadMul(targetBase).halfWadDiv(denominator);
        return expectedValue;
    }

    function _getActualValueForProportion(
        uint256 numerator,
        uint256 denominator,
        uint256 targetBase
    )
        internal
        pure
        returns(uint256)
    {
        uint256 actualValue
            = CalculationLib.calculatePropotion(numerator, denominator, targetBase);
        return actualValue;
    }
    






}