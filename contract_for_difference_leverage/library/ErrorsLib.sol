// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

library ErrorsLib {
    error PositionInfoEmpty();
    error InvalidLiquidationRange();
    error BaseTokenTransferFromFailed(uint256 inputTransferValue);
    error PositionInvaildOwner(uint256 id, address validOwner, address inputOwner);

}