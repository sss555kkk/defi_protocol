// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ILiquidityAndPositionInteractor} from '../interface/ILiquidityAndPositionInteractor.sol';
import {ParameterChecks} from '../utils/ParameterChecks.sol';
import {CalledChecks} from '../utils/CalledChecks.sol';

import {IReserveManager} from '../interface/IReserveManager.sol'; 
import {ILPToken} from '../interface/ILPToken.sol';
import {IPositionNFT} from '../interface/IPositionNFT.sol';
import {IFeeRateManager} from '../interface/IFeeRateManager.sol';
import {IMockToken} from '../mock/MockToken.sol';
import {MockOracle} from '../mock/MockOracle.sol';

import {CalculationLib} from '../library/CalculationLib.sol';
import {PositionValueLib} from '../library/PositionValueLib.sol';
import {PositionInfo} from '../domain/PositionInfo.sol';
import {ErrorsLib} from '../library/ErrorsLib.sol';


contract LiquidityAndPositionInteractor is 
    ILiquidityAndPositionInteractor, 
    ParameterChecks, 
    CalledChecks
{
    
    using PositionValueLib for PositionInfo;    
    
    IReserveManager public reserveManager;
    ILPToken public lpToken;
    IPositionNFT public positionNFT;
    IFeeRateManager public feeRateManager;
    MockOracle public oracle;
    IMockToken public baseToken;


    function Initialize(
        address _lpToken,
        address _positionNFT,
        address _reserveManager,
        address _feeRateManager,
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
        baseToken = IMockToken(_baseToken);
        oracle = MockOracle(_oracle);
    }

    function deposit(
        uint256 _amount
    )
        external
        checkIntegerZero(_amount)
        returns(uint256)
    {
        (uint256 depositAmount, uint256 reserveBeforeDeposit) 
            = _receiveBaseTokenFromUser(_amount);
        
        uint256 lpTokenMintAmount = _calculateLpTokenMintAmount(
            depositAmount,
            reserveBeforeDeposit
        );
        _callLpTokenMint(msg.sender, lpTokenMintAmount);
        emit DepositLiquidity(msg.sender, depositAmount);
        return lpTokenMintAmount;
    }

    function redeem(
        uint256 _lpTokenRedeemAmount
    )
        external
        checkIntegerZero(_lpTokenRedeemAmount)
        returns(uint256)
    {
        uint256 baseTokenRedeemAmount = _calculateBaseTokenRedeemAmount(
            _lpTokenRedeemAmount
        );
        _callLpTokenBurn(msg.sender, _lpTokenRedeemAmount);
        _sendBaseTokenToUser(msg.sender, baseTokenRedeemAmount);
        
        emit RedeemLiquidity(msg.sender, baseTokenRedeemAmount);
        return baseTokenRedeemAmount;
    }

    function buyPosition(
        bool _isLong,
        uint256 _amount,
        uint8 _leverage
    )
        external
        checkIntegerZero(_amount)
        checkValidLeverageRange(_leverage)
        returns(uint256)
    {
        (uint256 buyAmount, ) = _receiveBaseTokenFromUser(_amount);
        uint256 newPositionId = _callPositionNFTMint(
            msg.sender,
            _isLong,
            buyAmount,
            _leverage
        );
        emit BuyPosition(msg.sender, newPositionId);
        return newPositionId;
    }

    function clearPosition(
        uint256 _id
    )
        external
        returns(uint256)
    {
        _checkPositionValidOwner(_id);
        uint256 positionValueBeforeFee = _calculatePositionValue(_id);
        uint256 positionValueAfterFee = _calculateValueAfterFee(positionValueBeforeFee);
        _callpositionNFTBurn(_id);
        _sendBaseTokenToUser(msg.sender, positionValueAfterFee);
        
        emit ClearPosition(msg.sender, positionValueAfterFee);
        return positionValueAfterFee;
    }

    function _receiveBaseTokenFromUser(
        uint256 _amount
    )
        internal
        returns(uint256, uint256)
    {
        uint256 reserveBeforeDeposit = _getReserve();
        bool success = baseToken.transferFrom(
            msg.sender, 
            address(reserveManager), 
            _amount
        );
        if (success != true) {
            revert ErrorsLib.BaseTokenTransferFromFailed(_amount);
        }
        uint256 depositAmount = _getReserve() - reserveBeforeDeposit;
        return (depositAmount, reserveBeforeDeposit);
    }

    function _sendBaseTokenToUser(
        address _to,
        uint256 _amount
    )
        internal
    {
        reserveManager.transferToUser(_to, _amount);
    }

    function _calculateLpTokenMintAmount(
        uint256 baseTokendepositAmount,
        uint256 baseTokenReserveBeforeDeposit
    )
        internal
        view
        returns(uint256)
    {
        uint256 mintAmount = (baseTokenReserveBeforeDeposit==0)
            ? baseTokendepositAmount
            : CalculationLib.calculatePropotion(
                baseTokendepositAmount,
                baseTokenReserveBeforeDeposit,
                _getLpTokenTotalSupply()
            );
        return mintAmount;
    }

    function _calculateBaseTokenRedeemAmount(
        uint256 _lpTokenRedeemAmount
    )
        internal
        view
        returns(uint256)
    {
        uint256 baseTokenRedeemAmount = CalculationLib.calculatePropotion(
            _lpTokenRedeemAmount,
            _getLpTokenTotalSupply(),
            _getReserve()
        );
        return baseTokenRedeemAmount;
    }

    function _callLpTokenMint(
        address _to,
        uint256 _lpTokenMintAmount
    )
        internal
    {
        lpToken.mintOnDeposit(_to, _lpTokenMintAmount);
    }

    function _callLpTokenBurn(
        address _to,
        uint256 _lpTokenburnAmount
    )
        internal
    {
        lpToken.burnOnRedeem(_to, _lpTokenburnAmount);
    }

    function _callPositionNFTMint(
        address _sender,
        bool _isLong,
        uint256 _buyAmount,
        uint8 _leverage
    )
        internal
        returns(uint256)
    {
        PositionInfo memory positionInfo = PositionInfo(
            _getCurrentIndex(),
            _isLong,
            _buyAmount,
            _leverage
        );
        uint256 newPositionId = positionNFT.mintOnBuyPosition(
            _sender,
            positionInfo
        );
        return newPositionId;
    }

    function _callpositionNFTBurn(
        uint256 _id
    )
        internal
    {
        positionNFT.burnOnClearPostion(_id);
    }

    function _calculatePositionValue(
        uint256 _id
    )
        internal
        view
        returns(uint256)
    {
        PositionInfo memory positionInfo = positionNFT.positionInfos(_id);
        uint256 positionValue = positionInfo.calculatePositionValue(
            _getCurrentIndex()
        );
        return positionValue;
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

    function _checkPositionValidOwner(
        uint256 _id
    )
       internal
       view
    {
        if (positionNFT.ownerOf(_id) != msg.sender) {
            revert ErrorsLib.PositionInvaildOwner(
                _id,
                positionNFT.ownerOf(_id),
                msg.sender
            );
        }
    }

    function _getReserve()
        internal
        view
        returns(uint256)
    {
        return baseToken.balanceOf(address(reserveManager));
    }

    function _getLpTokenTotalSupply()
        internal
        view
        returns(uint256)
    {
        return lpToken.totalSupply();
    }

    function _getCurrentIndex()
        internal
        view 
        returns(uint256)
    {
        return oracle.getIndex();
    }

    function _getFeeRate()
        internal
        view
        returns(uint256)
    {
        return feeRateManager.feeRate();
    }
}











