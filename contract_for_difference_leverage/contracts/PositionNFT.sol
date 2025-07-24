// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IPositionNFT} from '../interface/IPositionNFT.sol';
import {ValidCallersChecks} from '../utils/ValidCallersChecks.sol';
import {NFTChecks} from '../utils/NFTChecks.sol';

import {PositionInfo} from '../domain/PositionInfo.sol';

contract PositionNFT is 
    IPositionNFT,
    ValidCallersChecks,
    NFTChecks

{

    uint256 private _idCounter;
    mapping (uint256=>PositionInfo) private _positionInfos;

    constructor(
        address _liquidityAndPositionInteractor,
        address _liquidationInteractor
    ) 
    {
        validCaller1 = _liquidityAndPositionInteractor;
        validCaller2 = _liquidationInteractor;
    }

    function mintOnBuyPosition(
        address _to,
        PositionInfo memory _positionInfo
    )
        external
        onlyValidCaller1
        returns(uint256)
    {
        increaseIdCounter();
        _mint(_to, _positionInfo);

        return _idCounter;
    }

    

    function burnOnClearPostion(
        uint256 _id
    )
        external
        onlyValidCallers
    {
        _burn(_id);
    }

    function transfer(
        address _to, 
        uint256 _id
    ) 
        external
        checkValidOwner(_id, msg.sender)
        returns(bool)  
    {
        _transferOrBurn(_to, _id);
        emit Transfer(msg.sender, _to, _id);
        return true;
    }

    function transferFrom(
        address _from, 
        address _to, 
        uint256 _id
    ) 
        external
        checkValidOwner(_id, _from)
        checkValidAllowance(_id, _from, msg.sender)
        returns(bool)  
    {
        _transferOrBurn(_to, _id);
        delete _allowance[_id][_from];

        emit Transfer(_from, _to, _id);
        return true;
    }

    function _transferOrBurn(
        address _to, 
        uint256 _id
    )
        internal
    {
        if (_to != address(0)) {
            _transfer(_to, _id);
        } else {
            _burn(_id);
        }
    }

    function _transfer(
        address _to,
        uint256 _id
    )
        internal
    {
        _ownerOf[_id] = _to;
    }

    function _mint(
        address _to,
        PositionInfo memory _positionInfo
    )
        internal
    {
        _ownerOf[_idCounter] = _to;
        _positionInfos[_idCounter] = _positionInfo;
    }

    function _burn(
        uint256 _id
    )
        internal
    {
        delete _ownerOf[_id];
        delete _positionInfos[_id];
    }

    function approve(
        address _spender, 
        uint256 _id
    ) 
        external
        checkValidOwner(_id, msg.sender)
        returns(bool)  
    {
        _allowance[_id][msg.sender] = _spender; 

        emit Approve(msg.sender, _spender, _id);
        return true;
    }

    function increaseIdCounter()
        internal
    {
        _idCounter += 1;
    }

    function positionInfos(
        uint256 _id
    )
        external
        view
        returns(PositionInfo memory)
    {
        return _positionInfos[_id];
    }

    function idCounter() 
        external 
        view 
        returns(uint256)
    {
        return _idCounter;
    }

    function ownerOf(
        uint256 _id
    ) 
        external 
        view 
        returns(address)
    {
        return _ownerOf[_id];
    }

    function allowance(
        uint256 _id,
        address _owner
    ) 
        external 
        view 
        returns(address)
    {
        return _allowance[_id][_owner];
    }
}