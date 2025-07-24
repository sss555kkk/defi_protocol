
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IReserveManager} from '../interface/IReserveManager.sol'; 
import {ValidCallersChecks} from '../utils/ValidCallersChecks.sol';

import {MockToken} from '../mock/MockToken.sol';

contract ReserveManager is 
    IReserveManager,
    ValidCallersChecks 
{
    MockToken public baseToken;

    constructor (
        address _baseToken,
        address _liquidityAndPositionInteractor
    ) 
    {
        baseToken = MockToken(_baseToken);
        validCaller1 = _liquidityAndPositionInteractor;
    }

    function transferToUser(
        address _to,
        uint256 _amount
    ) 
        external
        onlyValidCaller1 
    {
        baseToken.transfer(_to, _amount);
    }
}









