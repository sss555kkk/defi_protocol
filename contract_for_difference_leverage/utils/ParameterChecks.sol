// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import '../library/ParameterErrorsLib.sol';

contract ParameterChecks {
    
    modifier checkAddressZero(address addr) {
        if (addr == address(0)) {
            revert ParameterErrorsLib.AddressZero();
        }
        _;
    }

    modifier checkIntegerZero(uint256 num) {
        if (num == 0) {
            revert ParameterErrorsLib.IntegerZero();
        }
        _;
    }

    modifier checkValidLeverageRange(uint256 num) {
        if (num <1 || num>100) {
            revert ParameterErrorsLib.InvalidLeverageRange(num);
        }
        _;
    }
}