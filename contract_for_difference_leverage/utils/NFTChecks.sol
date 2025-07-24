// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import '../library/ParameterErrorsLib.sol';

contract NFTChecks {

    mapping (uint256=>address) internal _ownerOf;
    mapping (uint256=>mapping(address=>address)) internal _allowance;

    modifier checkValidOwner(
        uint256 id, 
        address owner
    ) 
    {
        if (_ownerOf[id] != owner) {
            revert ParameterErrorsLib.InvalidOwner(
                id, 
                _ownerOf[id], 
                owner
            );
        }
        _;
    }

    modifier checkValidAllowance(
        uint256 id, 
        address owner, 
        address spender
    ) 
    {
        if (_allowance[id][owner] != spender) {
            revert ParameterErrorsLib.InvalidAllowance(
                id, 
                _allowance[id][owner], 
                spender
            );
        }
        _;
    }



}