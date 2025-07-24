// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;



interface ILiquidityAndPositionInteractor {

    event DepositLiquidity(address sender, uint256 baseTokenDepositamount);
    event RedeemLiquidity(address sender, uint256 baseTokenRedeemamount);
    event BuyPosition(address sender, uint256 baseTokenBuyamount);
    event ClearPosition(address sender, uint256 baseTokenClearedPositionValue);

    function deposit(
        uint256 _amount
    )
        external
        returns(uint256);

    function redeem(
        uint256 _amount
    )
        external
        returns (uint256);

    function buyPosition(
        bool _isLong,
        uint256 _amount,
        uint8 _leverage
    )
        external
        returns(uint256);

    function clearPosition(
        uint256 _id
    )
        external
        returns(uint256);
}