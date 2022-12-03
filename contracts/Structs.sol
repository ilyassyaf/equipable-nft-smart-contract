// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library Structs {
    struct Yeye {
        bool exist;
        address creator;
        address owner;
        uint256 base;
        string[] equipped;
        mapping(string => uint256) traits;
    }

    struct Trait {
        bool exist;
        string category;
    }

    struct Category {
        bool exist;
        uint index;
    }
}