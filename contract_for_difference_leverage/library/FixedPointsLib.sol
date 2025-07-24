// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;


library FixedPointsLib {
    uint256 public constant halfWAD = 1e9;
    uint256 public constant quarterWAD = halfWAD/2;

    function halfWadMul(uint256 a, uint256 b) internal pure returns(uint256) {
        if (a==0 || b==0) {
            return 0;
        }
        return (a*b+quarterWAD)/halfWAD;
    }

    function halfWadDiv(uint256 a, uint256 b) internal pure returns(uint256) {
        if (b==0) {
            revert ("division by zero");
        }
        return (a*halfWAD+b/2)/b;
    }

    function halfWadMul(int256 a, int256 b) internal pure returns(int256) {
        if (a==0 || b==0) {
            return 0;
        }
        return (a*b+int256(quarterWAD))/int(halfWAD);
    }

    function halfWadDiv(int256 a, int256 b) internal pure returns(int256) {
        if (b==0) {
            revert ("division by zero");
        }
        if (a==0) {
            return 0;
        }
        return (a*int256(halfWAD)+b/2)/b;
    }
}
