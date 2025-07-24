// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

library ParameterErrorsLib {
    error AlreadyCalledOnce();
    error AddressZero();
    error IntegerZero();
    error InvalidLeverageRange(uint256 providedLeverage);
    error UnauthorizedCaller(address caller);
    error InsufficientBalance(uint256 available, uint256 required);
    error InsufficientAllowance(uint256 available, uint256 required);
    error InvalidOwner(uint256 id, address realOwner, address inputOwner);
    error InvalidAllowance(uint256 id, address realSpender, address inputSpender);
}