// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ILPToken} from '../interface/ILPToken.sol';
import {ParameterChecks} from '../utils/ParameterChecks.sol';
import {ValidCallersChecks} from '../utils/ValidCallersChecks.sol';
import {TokenChecks} from '../utils/TokenChecks.sol';


contract LPToken is 
    ILPToken, 
    ParameterChecks,
    ValidCallersChecks,
    TokenChecks 

{
    
    uint256 private _totalSupply;
    string public tokenName;


    constructor(
        string memory _tokenName,
        address _liquidityAndPositionInteractor,
        address _liquidationInteractor
    ) 
    {
        tokenName = _tokenName;
        validCaller1 = _liquidityAndPositionInteractor;
        validCaller2 = _liquidationInteractor;
    }


    function mintOnDeposit(
        address _to,
        uint256 _amount
    )
        external
        checkIntegerZero(_amount) 
        onlyValidCallers
    {
        _mint(_to, _amount);
    }
    
    function burnOnRedeem(
        address _to,
        uint256 _amount
    )
        external
        checkIntegerZero(_amount) 
        onlyValidCaller1 
        checkBalance(_to, _amount)
    {
        _burn(_to, _amount);
    }

    function transfer(
        address _to, 
        uint256 _amount
    ) 
        external 
        checkIntegerZero(_amount) 
        checkBalance(msg.sender, _amount) 
        returns(bool) 
    {
        _transferOrBurn(msg.sender, _to, _amount);
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(
        address _from, 
        address _to, 
        uint256 _amount
    ) 
        external 
        checkIntegerZero(_amount) 
        checkBalance(_from, _amount)
        checkAllowance(_from, msg.sender, _amount)
        returns(bool) 
    {
        _transferOrBurn(_from, _to, _amount);
        _allowance[_from][msg.sender] -= _amount;
        emit Transfer(_from, _to, _amount);
        return true;
    }

    function _transferOrBurn(
        address _from, 
        address _to, 
        uint256 _amount
    )
        internal
    {
        if (_to != address(0)) {
            _transfer(_from, _to, _amount);
        } else {
            _burn(_from, _amount);
        }
    }
    
    function _transfer(
        address _from, 
        address _to,
        uint256 _amount
    ) 
        internal 
    {
        _balanceOf[_from] -= _amount;
        _balanceOf[_to] += _amount;
    }

    function approve(
        address _spender, 
        uint256 _amount
    ) 
        external 
        checkIntegerZero(_amount)
        checkAddressZero(_spender)
        checkBalance(msg.sender, _amount) 
        returns(bool) 
    {
        _allowance[msg.sender][_spender] += _amount;
        emit Approve(msg.sender, _spender, _amount);
        return true;
    }

    function _mint(
        address _owner, 
        uint256 _amount
    ) 
        internal 
    {
        _balanceOf[_owner] += _amount;
        _totalSupply += _amount;
    }

    function _burn(
        address _owner, 
        uint256 _amount
    ) 
        internal 
    {
        _balanceOf[_owner] -= _amount;
        _totalSupply -= _amount;
    }

    function totalSupply() 
        external 
        view 
        returns(uint256)
    {
        return _totalSupply;
    }

    function balanceOf(
        address account
    ) 
        external 
        view 
        returns(uint256)
    {
        return _balanceOf[account];
    }

    function allowance(
        address owner, 
        address spender
    ) 
        external 
        view 
        returns(uint256)
    {
        return _allowance[owner][spender];
    }
}



