
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ILiquidationInteractor} from '../interface/ILiquidationInteractor.sol';
import {ParameterChecks} from '../utils/ParameterChecks.sol';
import {CalledChecks} from '../utils/CalledChecks.sol';

import {IReserveManager} from '../interface/IReserveManager.sol'; 
import {ILPToken} from '../interface/ILPToken.sol';
import {IPositionNFT} from '../interface/IPositionNFT.sol';
import {IFeeRateManager} from '../interface/IFeeRateManager.sol';
import {ILiquidationRatioManager} from '../interface/ILiquidationRatioManager.sol';
import {IMockToken} from '../mock/IMockToken.sol';
import {MockOracle} from '../mock/MockOracle.sol';


import {CalculationLib} from '../library/CalculationLib.sol';
import {PositionValueLib} from '../library/PositionValueLib.sol';
import {FixedPointsLib} from '../library/FixedPointsLib.sol';
import {PositionInfo} from '../domain/PositionInfo.sol';
import {ErrorsLib} from '../library/ErrorsLib.sol';


contract LiquidationInteractor is 
    ILiquidationInteractor, 
    ParameterChecks, 
    CalledChecks 
{
    
    using PositionValueLib for PositionInfo;
    using FixedPointsLib for uint256;
    
    IReserveManager public reserveManager;
    ILPToken public lpToken;
    IPositionNFT public positionNFT;
    IFeeRateManager public feeRateManager;
    ILiquidationRatioManager public liquidationRatioManager;
    IMockToken public baseToken;
    MockOracle public oracle;
    

    function Initialize(
        address _lpToken,
        address _positionNFT,
        address _reserveManager,
        address _feeRateManager,
        address _liquidationRatioManager,
        address _baseToken,
        address _oracle
    )
        external
        onlyOnceCalled
    {
        lpToken = ILPToken(_lpToken);
        positionNFT = IPositionNFT(_positionNFT);
        reserveManager = IReserveManager(_reserveManager);
        feeRateManager = IFeeRateManager(_feeRateManager);
        liquidationRatioManager = ILiquidationRatioManager(_liquidationRatioManager);
        baseToken = IMockToken(_baseToken);
        oracle = MockOracle(_oracle);
    }

    function liquidatePosition(
        uint256 _id
    )
        external
        checkIntegerZero(_id)
        returns(uint256)
    {
        PositionInfo memory positionInfo = positionNFT.positionInfos(_id);
        bool isPositionInfoEmpty = _isPositionInfoEmpty(positionInfo.amount);
        if (isPositionInfoEmpty == true) {
            revert ErrorsLib.PositionInfoEmpty();
        }
        uint256 positionValueBeforeFee = _calculatePositionValue(
            positionInfo
        );
        bool isLiquidationRange = _isValidLiquidationRange(
            positionValueBeforeFee,
            positionInfo.amount
        );
        if (isLiquidationRange == false) {
            revert ErrorsLib.InvalidLiquidationRange();
        }
        uint256 positionValueAfterFee = _calculateValueAfterFee(
            positionValueBeforeFee
        );
        uint256 lpTokenMintAmount = _calculateLPTokenMintAmount(
            positionValueAfterFee
        );
        if (lpTokenMintAmount != 0) {
            _callLPTokenMint(msg.sender, lpTokenMintAmount);
        }
        positionNFT.burnOnClearPostion(_id);
        emit LiquidatePosition(_id, msg.sender);
        return lpTokenMintAmount;
    }

    function isValidLiquidationRange(
        uint256 _id
    )
        external
        view
        returns(bool)
    {
        PositionInfo memory positionInfo = positionNFT.positionInfos(_id);
        bool isPositionInfoEmpty = _isPositionInfoEmpty(positionInfo.amount);
        if (isPositionInfoEmpty == true) {
            return false;
        }
        uint256 currentPositionValue = _calculatePositionValue(
            positionInfo
        );
        bool isLiquidationRange = _isValidLiquidationRange(
            currentPositionValue,
            positionInfo.amount
        );
        return isLiquidationRange;
    }

    function _isPositionInfoEmpty(
        uint256 _positionAmount
    )
        internal
        pure
        returns(bool)
    {
        if (_positionAmount == 0) {
            return true;
        } else {
            return false;
        }
    }

    function _calculatePositionValue(
        PositionInfo memory positionInfo
    )
        internal
        view
        returns(uint256)
    {
        uint256 currentPositionValue = positionInfo.calculatePositionValue(
            _getCurrentIndex()
        );
        return currentPositionValue;
    }

    function _isValidLiquidationRange(
        uint256 currentValue,
        uint256 valueAtCreation
    )
        internal
        view
        returns(bool)
    {
        if (currentValue <= valueAtCreation.halfWadMul(_getLiquidationRatio())) {
            return true;
        } else {
            return false;
        }
    }

    function _calculateValueAfterFee(
        uint256 positionValueBeforeFee
    )
        internal
        view
        returns(uint256)
    {
        uint256 positionValueAfterFee = CalculationLib.calculateValueAfterFee(
            positionValueBeforeFee,
            _getFeeRate()
        );
        return positionValueAfterFee;
    }

    function _calculateLPTokenMintAmount(
        uint256 positionValueAfterFee
    )
        internal
        view
        returns(uint256)
    {
        uint256 lpTokenMintAmount = CalculationLib.calculatePropotion(
            positionValueAfterFee,
            _getReserve()-positionValueAfterFee,
            _getLpTokenTotalSupply()
        );
        return lpTokenMintAmount;
    }

    function _callLPTokenMint(
        address _to,
        uint256 _lpTokenMintAmount
    )
        internal
    {
        lpToken.mintOnDeposit(_to, _lpTokenMintAmount);
    }

    function _getLpTokenTotalSupply()
        internal
        view
        returns(uint256)
    {
        return lpToken.totalSupply();
    }

    function _getFeeRate()
        internal
        view
        returns(uint256)
    {
        return feeRateManager.feeRate();
    }
    
    function _getCurrentIndex()
        internal 
        view
        returns(uint256)
    {
        return oracle.getIndex();
    }

    function _getLiquidationRatio()
        internal
        view
        returns(uint256)
    {
        return liquidationRatioManager.liquidationRatio();
    }

    function _getReserve()
        internal
        view
        returns(uint256)
    {
        return baseToken.balanceOf(address(reserveManager));
    }
}


















