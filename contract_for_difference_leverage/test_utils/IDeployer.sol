// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {MockToken} from '../mock/MockToken.sol';
import {MockOracle} from '../mock/MockOracle.sol';

import {ILiquidityAndPositionInteractor} from '../interface/ILiquidityAndPositionInteractor.sol';
import {ILiquidationInteractor} from '../interface/ILiquidationInteractor.sol';
import {ILPToken} from '../interface/ILPToken.sol';
import {IPositionNFT} from '../interface/IPositionNFT.sol';
import {IReserveManager} from '../interface/IReserveManager.sol';
import {IFeeRateManager} from '../interface/IFeeRateManager.sol';
import {ILiquidationRatioManager} from '../interface/ILiquidationRatioManager.sol';


interface IDeployer {

    function baseToken() external view returns(address);
    function oracle() external view returns(address);
    
    function liquidityAndPositionInteractor() external view returns(address);
    function liquidationInteractor() external view returns(address);
    function lpToken() external view returns(address);
    function positionNFT() external view returns(address);
    function reserveManager() external view returns(address);
    function feeRateManager() external view returns(address);
    function liquidationRatioManager() external view returns(address);
}