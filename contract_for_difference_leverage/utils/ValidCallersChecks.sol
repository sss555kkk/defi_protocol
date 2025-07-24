// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import '../library/ParameterErrorsLib.sol';

contract ValidCallersChecks {

    address public validCaller1;
    address public validCaller2;

    modifier onlyValidCaller1() {
        if (msg.sender != validCaller1) {
            revert ParameterErrorsLib.UnauthorizedCaller(msg.sender);
        }
        _;
    }

    modifier onlyValidCaller2() {
        if (msg.sender != validCaller2) {
            revert ParameterErrorsLib.UnauthorizedCaller(msg.sender);
        }
        _;
    }
    
    modifier onlyValidCallers() {
        if ((msg.sender != validCaller1) && (msg.sender != validCaller2)) {
            revert ParameterErrorsLib.UnauthorizedCaller(msg.sender);
        }
        _;
    }
}