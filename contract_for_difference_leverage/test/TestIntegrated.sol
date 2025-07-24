// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/*
사용방법
(1) Deployer를 먼저 Deploy 함.Deployer의 initialize 함수 호출.
(2) deployer 주소를 이용해서 transaction maker 인스턴스 배포.
(3) deployer 주소를 이용해서 test interactors 인스턴스 배포.
(4) 테스트 순서
    tx maker: deposit
    test interactors: deposit
    tx maker: buyPosition
    tx maker: change index
    tx maker: clear position
    tx maker: redeem
    test interactors: redeem
    test interactors: buyPosition
    tx maker: change index
    test interactors: clear Position
    test interactors: buyPosition
    tx maker: change index
    test interactors: liquidate Position

*/

import {IDeployer} from '../test_utils/IDeployer.sol';
import {IMockToken} from '../mock/IMockToken.sol';
import {MockOracle} from '../mock/MockOracle.sol';
import {ILiquidityAndPositionInteractor} 
    from '../interface/ILiquidityAndPositionInteractor.sol';
import {ILiquidationInteractor} 
    from '../interface/ILiquidationInteractor.sol';
import {ILPToken} from '../interface/ILPToken.sol';
import {IPositionNFT} from '../interface/IPositionNFT.sol';
import {IFeeRateManager} from '../interface/IFeeRateManager.sol';
import {ILiquidationRatioManager} from '../interface/ILiquidationRatioManager.sol';
import {IReserveManager} from '../interface/IReserveManager.sol';
import {
    DummyDepositor, 
    DummyTrader, 
    DummyLiquidationCaller
} from '../test_utils/DummyPlayers.sol';

import {PositionInfo} from '../domain/PositionInfo.sol';

import {FixedPointsLib} from '../library/FixedPointsLib.sol';
import {CalculationLib} from '../library/CalculationLib.sol';
import {PositionValueLib} from '../library/PositionValueLib.sol';


contract TestIntegrated {
    using FixedPointsLib for uint256;
    using PositionValueLib for PositionInfo;

    address public testDepositor;
    address public testTrader;
    uint256 public testTraderPositionId;
    uint256 public testLiquidationId;


    IMockToken public baseToken;
    MockOracle public oracle;
    ILiquidityAndPositionInteractor public liquidityAndPositionInteractor;
    ILiquidationInteractor public liquidationInteractor;
    ILPToken public lpToken;
    IPositionNFT public positionNFT;
    IFeeRateManager public feeRateManager;
    ILiquidationRatioManager public liquidationRatioManager;
    IReserveManager public reserveManager;

    constructor(address _deployer) {
        IDeployer deployer = IDeployer(_deployer);
        baseToken = IMockToken(deployer.baseToken());
        oracle = MockOracle(deployer.oracle());
        liquidityAndPositionInteractor 
            = ILiquidityAndPositionInteractor(
                deployer.liquidityAndPositionInteractor()
            );
        liquidationInteractor 
            = ILiquidationInteractor(deployer.liquidationInteractor());
        lpToken = ILPToken(deployer.lpToken());
        positionNFT = IPositionNFT(deployer.positionNFT());
        feeRateManager = IFeeRateManager(deployer.feeRateManager());
        liquidationRatioManager 
            = ILiquidationRatioManager(deployer.liquidationRatioManager());
        reserveManager = IReserveManager(deployer.reserveManager());
    }

    function testDeposit(
        uint256 _amount
    )
        public
    {
        DummyDepositor depositor = new DummyDepositor(
            address(liquidityAndPositionInteractor),
            address(baseToken)
        );
        testDepositor = address(depositor);

        uint256 expectedLPTokenMintAmount 
            = CalculationLib.calculatePropotion(
                _amount,
                baseToken.balanceOf(address(reserveManager)),
                lpToken.totalSupply()
            );

        depositor.deposit(_amount);
        uint256 actualLPTokenMintAmount 
            = lpToken.balanceOf(address(depositor));
        assert (expectedLPTokenMintAmount == actualLPTokenMintAmount);
    }

    function testRedeem()
        public
    {
        DummyDepositor depositor = DummyDepositor(testDepositor);
        
        uint256 expectedBaseTokenRedeemAmount
            = CalculationLib.calculatePropotion(
                lpToken.balanceOf(testDepositor),
                lpToken.totalSupply(),
                baseToken.balanceOf(address(reserveManager))
            );

        depositor.redeem(lpToken.balanceOf(testDepositor));
        uint256 actualBaseTokenRedeemAmount 
            = baseToken.balanceOf(address(depositor));

        assert (expectedBaseTokenRedeemAmount == actualBaseTokenRedeemAmount);
    }

    function testBuyPosition(
        uint256 _amount
    )
        public
    {
        DummyTrader trader = new DummyTrader(
            address(liquidityAndPositionInteractor),
            address(baseToken)
        );
        uint256 id = trader.buyPosition(
            true,
            _amount,
            1
        );
        testTrader = address(trader);
        testTraderPositionId = id;

        PositionInfo memory actualStoragedInfo 
            = positionNFT.positionInfos(testTraderPositionId);
        
        assert (actualStoragedInfo.indexAtCreation == oracle.getIndex());
        assert (actualStoragedInfo.isLong == true);
        assert (actualStoragedInfo.amount == _amount);
        assert (actualStoragedInfo.leverage == 1);
    }

    function testClearPosition()
        public
    {        
        DummyTrader trader = DummyTrader(testTrader);
        PositionInfo memory storagedInfo 
            = positionNFT.positionInfos(testTraderPositionId);
        uint256 expectedPositionValueBeforeFee 
            = storagedInfo.calculatePositionValue(
                oracle.getIndex()
            );
        uint256 expectedPositionValueAfterFee
            = CalculationLib.calculateValueAfterFee(
                expectedPositionValueBeforeFee,
                feeRateManager.feeRate()
            );
        
        
        trader.clearPosition(testTraderPositionId);
        uint256 actualBaseTokenReceivingAmount 
            = baseToken.balanceOf(testTrader);

        assert (actualBaseTokenReceivingAmount == expectedPositionValueAfterFee);
    }

    function testLiquidatePosition()
        public 
    {
        DummyLiquidationCaller caller = new DummyLiquidationCaller(
            address(liquidationInteractor),
            address(baseToken)
        );

        PositionInfo memory storagedInfo 
            = positionNFT.positionInfos(testTraderPositionId);
        uint256 expectedPositionValueBeforeFee 
            = storagedInfo.calculatePositionValue(
                oracle.getIndex()
            );
        uint256 expectedPositionValueAfterFee
            = CalculationLib.calculateValueAfterFee(
                expectedPositionValueBeforeFee,
                feeRateManager.feeRate()
            );
        uint256 currentReserve = baseToken.balanceOf(address(reserveManager));
        uint256 reserveAfterCallerCompensation 
            = currentReserve - expectedPositionValueAfterFee;
        uint256 expectedLPTokenMintAmount =
            CalculationLib.calculatePropotion(
                expectedPositionValueAfterFee,
                reserveAfterCallerCompensation,
                lpToken.totalSupply()
            );
        
        caller.callLiquidation(testTraderPositionId);
        uint256 actualLPTokenMintAmount = lpToken.balanceOf(address(caller));

        assert (actualLPTokenMintAmount == expectedLPTokenMintAmount);
    }

}