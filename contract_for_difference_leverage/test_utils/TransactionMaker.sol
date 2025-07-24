// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IDeployer} from './IDeployer.sol';
import {IMockToken} from '../mock/IMockToken.sol';
import {ILiquidityAndPositionInteractor} 
    from '../interface/ILiquidityAndPositionInteractor.sol';
import {ILiquidationInteractor} 
    from '../interface/ILiquidationInteractor.sol';
import {ILPToken} from '../interface/ILPToken.sol';
import {IPositionNFT} from '../interface/IPositionNFT.sol';
import {MockOracle} from '../mock/MockOracle.sol';

import {
    DummyDepositor, 
    DummyTrader, 
    DummyLiquidationCaller
} from '../test_utils/DummyPlayers.sol';

/*
사용방법
(1) Deployer를 먼저 Deploy 함.
(2) Deployer의 initialize 함수 호출.
(3) TransactionMaker를 배포할때 constructor에 
배포한 deployer의 주소를 입력.

*/

contract TransactionMaker {

    mapping(uint8=>address) public depositors;
    mapping(uint8=>uint256) public depositorAmounts;
    mapping(uint8=>address) public traders;
    mapping(uint8=>uint256) public traderIds;


    IMockToken public baseToken;
    ILiquidityAndPositionInteractor public liquidityAndPositionInteractor;
    ILiquidationInteractor public liquidationInteractor;
    ILPToken public lpToken;
    IPositionNFT public positionNFT;
    MockOracle public oracle;

    constructor(address _deployer) {
        IDeployer deployer = IDeployer(_deployer);
        baseToken = IMockToken(deployer.baseToken());
        liquidityAndPositionInteractor = ILiquidityAndPositionInteractor(deployer.liquidityAndPositionInteractor());
        liquidationInteractor = ILiquidationInteractor(deployer.liquidationInteractor());
        lpToken = ILPToken(deployer.lpToken());
        positionNFT = IPositionNFT(deployer.positionNFT());
        oracle = MockOracle(deployer.oracle());
    }

    function makeDepositTransactions()
        public 
    {
        for (uint8 i=0; i<10; i++) {
            DummyDepositor newDepositor = new DummyDepositor(
                address(liquidityAndPositionInteractor),
                address(baseToken)
            );
            newDepositor.deposit(1000e9);
            depositors[i] = address(newDepositor);
            depositorAmounts[i] = 1000e9;
        }
    }

    function makeRedeemTransactions()
        public 
    {

        for (uint8 i=0; i<5; i++)  {
            DummyDepositor depositor = DummyDepositor(depositors[i]);
            depositor.redeem(depositorAmounts[i]);

            delete depositors[i];
            delete depositorAmounts[i];
        }
    }

    function makeBuyPositionTransactions()
        public 
    {
        for (uint8 i=0; i<10; i++)  {
            DummyTrader newTrader = new DummyTrader(
                address(liquidityAndPositionInteractor),
                address(baseToken)
            );
            uint256 id = newTrader.buyPosition(
                true,
                100e9,
                1
            );
            traders[i] = address(newTrader);
            traderIds[i] = id;
        }
    }

    function makeClearPositionTransactions()
        public 
    {
        for (uint8 i=0; i<5; i++)  {
            DummyTrader trader = DummyTrader(traders[i]);
            trader.clearPosition(traderIds[i]);

            delete traders[i];
            delete traderIds[i];
        }
    }

    function changeIndex(
        uint256 _newIndex
    )
        external
    {
        oracle.setIndex(_newIndex);
    }
}