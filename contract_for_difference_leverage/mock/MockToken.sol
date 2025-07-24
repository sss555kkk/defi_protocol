// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IMockToken} from './IMockToken.sol';

contract MockToken is IMockToken {
    event Transfer(address from, address to, uint256 amount);
    event Approve(address owner, address spender, uint256 amount);
    
    uint256 private _totalSupply;
    mapping (address=>uint256) private _balanceOf;
    mapping (address=>mapping(address=>uint256)) private _allowance;
    string private _tokenName;


    constructor(string memory _tokenNameParam) {
        _tokenName = _tokenNameParam;
    }

    function mint(address _recipient, uint256 _amount) external {
        if (_recipient == address(0)) {
            revert();
        }
        _mint(_recipient, _amount);
        emit Transfer(address(0), _recipient, _amount);
    }

    function transfer(address _recipient, uint256 _amount) external returns(bool) {
        require (_balanceOf[msg.sender] >= _amount, 'not enough balance');
        _transfer(msg.sender, _recipient, _amount);
        emit Transfer(msg.sender, _recipient, _amount);
        return true;
    }

    function transferFrom(
        address _owner, 
        address _recipient, 
        uint256 _amount
    ) external returns(bool) {
        require (_balanceOf[_owner] >= _amount, 'not enough balance');
        require (_allowance[_owner][msg.sender] >= _amount, 'invalid _allowance');
        _transfer(_owner, _recipient, _amount);
        _allowance[_owner][msg.sender] -= _amount;
        emit Transfer(_owner, _recipient, _amount);
        return true;
    }
    
    function _transfer(
        address _sender, 
        address _recipient, 
        uint256 _amount
    ) internal {
        if (_recipient == address(0)) {
            _burn(_sender, _amount);
            return;
        }
        _balanceOf[_sender] -= _amount;
        _balanceOf[_recipient] += _amount;
    }

    function approve(
        address _spender, 
        uint256 _amount
        ) external returns(bool) 
    {
        require (_balanceOf[msg.sender] >= _amount, 'not enough balance');
        _allowance[msg.sender][_spender] += _amount;
        emit Approve(msg.sender, _spender, _amount);
        return true;
    }
    
    function _mint(address _owner, uint256 _amount) internal {
        _balanceOf[_owner] += _amount;
        _totalSupply += _amount;
    }

    function _burn(address _owner, uint256 _amount) internal {
        _balanceOf[_owner] -= _amount;
        _totalSupply -= _amount;
    }

    function balanceOf(
        address owner
    )
        external
        view
        returns(uint256)
    {
        return _balanceOf[owner];
    }

    function totalSupply()
        external
        view
        returns(uint256)
    {
        return _totalSupply;
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

    function tokenName()
        external
        view
        returns(string memory)
    {
        return _tokenName;
    }
}
