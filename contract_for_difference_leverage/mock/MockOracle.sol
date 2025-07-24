// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;



contract MockOracle {


    uint256 public _index;

    function setIndex(
        uint256 _inputIndex
    )
        external
    {
        _index = _inputIndex;
    }

    function getIndex()
        external
        view
        returns(uint256)
    {
        return _index;
    }
}