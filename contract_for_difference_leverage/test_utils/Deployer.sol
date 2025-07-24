// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IDeployer} from './IDeployer.sol';

import {MockToken} from '../mock/MockToken.sol';
import {MockOracle} from '../mock/MockOracle.sol';

import {LiquidityAndPositionInteractor} from '../contracts/LiquidityAndPositionInteractor.sol';
import {LiquidationInteractor} from '../contracts/LiquidationInteractor.sol';
import {LPToken} from '../contracts/LPToken.sol';
import {PositionNFT} from '../contracts/PositionNFT.sol';
import {ReserveManager} from '../contracts/ReserveManager.sol';
import {FeeRateManager} from '../contracts/FeeRateManager.sol';
import {LiquidationRatioManager} from '../contracts/LiquidationRatioManager.sol';


contract Deployer {

    address public baseToken;
    address public oracle;
    
    address public liquidityAndPositionInteractor;
    address public liquidationInteractor;
    address public lpToken;
    address public positionNFT;
    address public reserveManager;
    address public feeRateManager;
    address public liquidationRatioManager;

    function initialize()
        public
    {
        MockToken bt = new MockToken('AAAToken');
        baseToken = address(bt);
        MockOracle mo = new MockOracle();
        mo.setIndex(100e9);
        oracle = address(mo);
        
        LiquidityAndPositionInteractor lpi = new LiquidityAndPositionInteractor();
        liquidityAndPositionInteractor = address(lpi);
        LiquidationInteractor li = new LiquidationInteractor();
        liquidationInteractor = address(li);
        LPToken lp = new LPToken(
            'aaa', 
            liquidityAndPositionInteractor,
            liquidationInteractor
        );
        lpToken = address(lp);
        PositionNFT nft = new PositionNFT(
            liquidityAndPositionInteractor,
            liquidationInteractor
        );
        positionNFT = address(nft);
        ReserveManager rm = new ReserveManager(
            baseToken,
            liquidityAndPositionInteractor
        );
        reserveManager = address(rm);
        FeeRateManager frm = new FeeRateManager(0.003e9);
        feeRateManager = address(frm);
        LiquidationRatioManager lrm = new LiquidationRatioManager(0.2e9);
        liquidationRatioManager = address(lrm);

        lpi.Initialize(
            lpToken,
            positionNFT,
            reserveManager,
            feeRateManager,
            baseToken,
            oracle
        );
        li.Initialize(
            lpToken,
            positionNFT,
            reserveManager,
            feeRateManager,
            liquidationRatioManager,
            baseToken,
            oracle
        );

    }
}

