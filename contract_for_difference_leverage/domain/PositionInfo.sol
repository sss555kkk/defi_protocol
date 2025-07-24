// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

struct PositionInfo {
    uint256 indexAtCreation;
    bool isLong;
    uint256 amount;
    uint8 leverage;
}

