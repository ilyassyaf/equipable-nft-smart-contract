// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./YeyeVault.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract YeyeFactory is AccessControl {
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    address public baseContract;
    address public traitContract;
    address public vaultContract;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(OWNER_ROLE, msg.sender);
    }

    /**
    * @dev assemble a YEYE complete structure
    */
    function equipTraits(uint256 _id, uint256 base, uint256[] calldata traits) public {
        /*
        TODO: Equip base with trait
        1. check each trait if there's overrider (legend rarity) : throw error, legendary overrides
        2. check if _id already exist ? create new from Blueprint
        3. else _id is equipped nft ? get Blueprint
        4. check balance base nft
        5. check balance each trait nft
        6. check traits cat
        7. withdraw base & traits if exist
        8. fill in Blueprint
        9. store base & traits to vault
        10. save Blueprint
        11. burn base & traits
        12. mint equipped if new
        13. emit event
        */
    }

    /**
    * @dev disassemble a YEYE complete structure
    */
    function unequipTraits(uint256 _tokenID) public {
        /*
        TODO: unequip to withdraw base & traits
        1. check _tokenID balance
        2. check if _tokenID is a valid equipped nft
        3. withdraw base & traits
        4. burn _tokenID
        5. emit event
        */
    }

    /**
    * @dev send sender's token to vault if sufficient
     */
    // function sendToVault(Structs.Yeye memory yeye) private {
    //     if (balanceOf(msg.sender, yeye.base) < 1) revert Insufficient("Insufficient balance");
    //     _balances[yeye.base][msg.sender] --;
    //     for (uint i = 0; i < yeye.traits.length; i++) {
    //         if (balanceOf(msg.sender, yeye.traits[i]) < 1) revert Insufficient("Insufficient balance");
    //         _balances[yeye.traits[i]][msg.sender] --;
    //     }
        
    //     storeTo(msg.sender, yeye);
    // }

    /**
    * @dev withdraw sender's token from vault if sufficient
     */
    // function withdrawFromVault(Structs.Yeye memory yeye) private {
    //     withdrawFrom(msg.sender, yeye);
    //     _balances[yeye.base][msg.sender] ++;
    //     for (uint i = 0; i < yeye.traits.length; i++) {
    //         _balances[yeye.traits[i]][msg.sender] ++;
    //     }
    // }

    /*
    @dev function to create array with default value
    */
    function getRange(uint n, uint value) public pure returns(uint[] memory) {
        uint[] memory result = new uint[](n);
        for (uint i = 0; i < n; i++)
            result[i] = value;
        return result;
    }

    /*
    @dev function to list token to store
    */
    // function getTraitList(Structs.Yeye memory yeye) public pure returns(uint256[] memory) {
    //     uint len = yeye.traits.length + 1;
    //     uint256[] memory tokens = new uint256[](len);
    //     for (uint i = 0; i < tokens.length -1; i++) 
    //     {
    //         tokens[i] = yeye.traits[i].id;
    //     }
    //     tokens[tokens.length -1] = yeye.base;

    //     return tokens;
    // }
}
