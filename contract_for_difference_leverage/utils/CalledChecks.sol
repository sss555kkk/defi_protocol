// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;


contract CalledChecks {
    bool public isCalled = false;

    modifier onlyOnceCalled() {
        if (isCalled == true) {
            revert ("already once called!");
        }
        isCalled = true;
        _;
    }
}