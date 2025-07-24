// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IMockToken {

    function mint(address _recipient, uint256 _amount) external;

    function transfer(address _recipient, uint256 _amount) external returns(bool);

    function transferFrom(
        address _owner, 
        address _recipient, 
        uint256 _amount
    ) external returns(bool);
    


    function approve(
        address _spender, 
        uint256 _amount
        ) external returns(bool) ;
    


    function balanceOf(
        address owner
    )
        external
        view
        returns(uint256);

    function totalSupply()
        external
        view
        returns(uint256);

    function allowance(
        address owner,
        address spender
    )
        external
        view
        returns(uint256);

    function tokenName()
        external
        view
        returns(string memory);

}