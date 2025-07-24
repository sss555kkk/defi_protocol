// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import '../library/ParameterErrorsLib.sol';

contract TokenChecks {

    mapping (address=>uint256) internal _balanceOf;
    mapping (address=>mapping(address=>uint256)) internal _allowance;

    modifier checkBalance(
        address owner, 
        uint256 amount
    ) 
    {
        if(_balanceOf[owner] < amount) 
        {
            revert ParameterErrorsLib.InsufficientBalance(
                _balanceOf[owner], 
                amount
            );
        }
        _;
    }

    modifier checkAllowance(
        address owner, 
        address spender, 
        uint256 amount
    ) 
    {
        if (_allowance[owner][spender] < amount) 
        {
            revert ParameterErrorsLib.InsufficientAllowance(
                _allowance[owner][spender], 
                amount
            );
        }
        _;
    }
}

