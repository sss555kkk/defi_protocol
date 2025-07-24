// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {PositionInfo} from '../domain/PositionInfo.sol';

interface IPositionNFT {

    event Transfer(address from, address to, uint256 positionID);
    event Approve(address owner, address spender, uint256 positionID);

    function mintOnBuyPosition(
        address _to,
        PositionInfo memory _positionInfo
    )
        external
        returns(uint256);
    
    function burnOnClearPostion(
        uint256 _id
    )
        external;
    
    function transfer(
        address _recipient, 
        uint256 _positionID
        ) external returns(bool) ;

    function transferFrom(
        address _owner, 
        address _recipient, 
        uint256 _positionID
        ) external returns(bool) ;

    function approve(
        address _spender, 
        uint256 _positionID
        ) external returns(bool) ;

    function idCounter() external view returns(uint256);

    function ownerOf(uint256 _positionID) external view returns(address);

    function allowance(
        uint256 _positionID,
        address owner
    ) 
        external view returns(address);

    function positionInfos(
        uint256 _id
    )
        external
        view
        returns(PositionInfo memory);
    
    
}