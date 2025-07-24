// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/*
사용방법
(1) Deployer를 먼저 Deploy 함.
(2) Deployer의 initialize 함수 호출.
(3) StatesView를 배포할때 constructor에 
배포한 deployer의 주소를 입력.

*/

import {IDeployer} from './IDeployer.sol';
import {MockToken} from '../mock/MockToken.sol';
import {ILPToken} from '../interface/ILPToken.sol';
import {IPositionNFT} from '../interface/IPositionNFT.sol';


contract StatesViewer {

    mapping(string=>address) public nickNames;
    
    IDeployer public deployer;
    MockToken public baseToken;

    ILPToken public lpToken;
    IPositionNFT public positionNFT;


    constructor(address _deployer) {
        deployer = IDeployer(_deployer);
        baseToken = MockToken(deployer.baseToken());
        lpToken = ILPToken(deployer.lpToken());
        positionNFT = IPositionNFT(deployer.positionNFT());
    }

    function setAddress(
        string memory _nickName,
        address _addr
    )
        external
    {
        nickNames[_nickName] = _addr;
    }

    function viewAddressTokenInfo(
        string memory _nickName
    )
        external
        view
        returns(uint256,uint256,uint256,uint256)
    {
        address targetAddress = nickNames[_nickName];
        uint256 baseTokenBalance = baseToken.balanceOf(targetAddress);
        uint256 lpTokenBalance = lpToken.balanceOf(targetAddress);
        return (baseTokenBalance,baseTokenBalance/1e9, lpTokenBalance,lpTokenBalance/1e9);
    }

    function tokensTotalSupply()
        external
        view
        returns(uint256,uint256,uint256,uint256)
    {
        uint256 baseTotalSupply = baseToken.totalSupply();
        uint256 lpTotalSupply = lpToken.totalSupply();
        
        return (baseTotalSupply,baseTotalSupply/1e9,lpTotalSupply,lpTotalSupply/1e9);
    }

}