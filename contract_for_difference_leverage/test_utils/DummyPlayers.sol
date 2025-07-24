
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ILiquidityAndPositionInteractor} from '../interface/ILiquidityAndPositionInteractor.sol';
import {ILiquidationInteractor} from '../interface/ILiquidationInteractor.sol';
import {MockToken} from '../mock/MockToken.sol';

contract DummyDepositor {

    ILiquidityAndPositionInteractor public lpInteractor;
    MockToken public baseToken;

    constructor(
        address _lpInteractor,
        address _baseToken
    ) 
    {
        lpInteractor = ILiquidityAndPositionInteractor(_lpInteractor);
        baseToken = MockToken(_baseToken);
    }

    function deposit(
        uint256 _amount
    )
        external
    {
        baseToken.mint(address(this), _amount);
        baseToken.approve(address(lpInteractor), _amount);
        lpInteractor.deposit(_amount);
    }

    function redeem(
        uint256 _amount
    )
        external
    {
        lpInteractor.redeem(_amount);
    }
}


contract DummyTrader {

    ILiquidityAndPositionInteractor public lpInteractor;
    MockToken public baseToken;

    constructor(
        address _lpInteractor,
        address _baseToken
    ) 
    {
        lpInteractor = ILiquidityAndPositionInteractor(_lpInteractor);
        baseToken = MockToken(_baseToken);
    }

    function buyPosition(
        bool _isLong,
        uint256 _amount,
        uint8 _leverage
    )
        external
        returns(uint256)
    {
        baseToken.mint(address(this), _amount);
        baseToken.approve(address(lpInteractor), _amount);
        uint256 id = lpInteractor.buyPosition(_isLong, _amount, _leverage);
        return id;
    }

    function clearPosition(
        uint256 _id
    )
        external
        returns(uint256)
    {
        uint256 receivedAmount = lpInteractor.clearPosition(_id);
        return receivedAmount;
    }
}


contract DummyLiquidationCaller {

    ILiquidationInteractor public liquidationInteractor;
    MockToken public baseToken;

    constructor(
        address _liquidationInteractor,
        address _baseToken
    ) 
    {
        liquidationInteractor = ILiquidationInteractor(_liquidationInteractor);
        baseToken = MockToken(_baseToken);
    }

    function callLiquidation(
        uint256 _id
    )
        external
        returns(uint256)
    {
        uint256 receivedLPTokenAmount = liquidationInteractor.liquidatePosition(_id);
        return receivedLPTokenAmount;
    }
}
