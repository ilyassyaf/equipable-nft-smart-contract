// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Structs.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

abstract contract Traits {
    using SafeMath for uint256;

    string[] private _categories;

    mapping (string => Structs.Category) internal categoryCheck;
    mapping (uint => uint256[]) internal traits;
    mapping (uint256 => Structs.Trait) private traitCheck;

    error TraitNotExist(string message);
    error CategoryExist(string message);

    function _addTrait(uint256 id, string calldata _category) internal {
        Structs.Category memory cat = categoryCheck[_category];
        if (!cat.exist) revert CategoryExist("Category not exist");
        Structs.Trait memory newTrait = Structs.Trait(
            true, // exist
            _category // category
        );
        traits[cat.index].push(id);
        traitCheck[id] = newTrait;
    }

    function getTraits(string memory category) public view returns (uint256[] memory) {
        return traits[categoryCheck[category].index];
    }

    function checkTrait(uint256 _id) internal view returns (Structs.Trait memory) {
        return traitCheck[_id];
    }

    function addCategory(string memory newCategory) public virtual {
        Structs.Category memory cat = categoryCheck[newCategory];
        if (cat.exist) revert CategoryExist("Category already exist");
        _categories.push(newCategory);
        uint256 IDX = _categories.length - 1;
        Structs.Category memory category = Structs.Category(
            true,
            IDX
        );
        categoryCheck[newCategory] = category;
    }

    function allCategories() public view returns (string[] memory) {
        return _categories;
    }

    function categoryOf(uint256 id) public view returns (string memory) {
        Structs.Trait memory trait = traitCheck[id];
        if (!trait.exist) revert TraitNotExist("Trait not exist");
        return trait.category;
    }
}