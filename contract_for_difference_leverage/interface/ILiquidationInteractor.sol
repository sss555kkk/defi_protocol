// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface ILiquidationInteractor {

    event LiquidatePosition(uint256 id, address caller);

    function liquidatePosition(
        uint256 _id
    )
        external 
        returns(uint256);

    function isValidLiquidationRange(
        uint256 _id
    )
        external
        view
        returns(bool);
}