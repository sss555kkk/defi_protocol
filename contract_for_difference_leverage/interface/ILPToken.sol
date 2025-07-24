// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface ILPToken {
    event Transfer(address from, address to, uint256 amount);
    event Approve(address owner, address spender, uint256 amount);

    function mintOnDeposit(
        address _to,
        uint256 _amount
    )
        external;
    
    function burnOnRedeem(
        address _to,
        uint256 _amount
    )
        external;

    function transfer(
        address _recipient, 
        uint256 _amount
        ) external returns(bool) ;

    function transferFrom(
        address _owner, 
        address _recipient, 
        uint256 _amount
        ) external returns(bool) ;

    function approve(
        address _spender, 
        uint256 _amount
        ) external returns(bool) ;
    
    function totalSupply() external view returns(uint256);

    function balanceOf(address account) external view returns(uint256);

    function allowance(
        address owner, 
        address spender
    ) 
        external view returns(uint256);
}