// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./ERC1155Burnable.sol";
import "./ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract YeyeTrait is ERC1155, AccessControl, ERC1155Burnable, ERC1155Supply {
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant VAULT_ROLE = keccak256("VAULT_ROLE");
    bytes32 public constant FACTORY_ROLE = keccak256("FACTORY_ROLE");

    // Name of collection
    string public name = "YEYE Factory: Traits";

    // Trait Blueprint
    struct TraitBlueprint {
        bool exist; // check if trait exist
        string category; // trait category
        bool overrides; // check if trait cannot be equipped with others (legendary trait)
    }
    mapping(uint256 => TraitBlueprint) public traits;

    // category mapping
    struct Category {
        bool exist;
        uint256 index;
    }
    mapping(string => Category) public categoryCheck;
    string[] public categories;


    constructor(string memory _uri) ERC1155(_uri) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(URI_SETTER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(FACTORY_ROLE, msg.sender);
    }

    function addCategory(string memory newCategory) public onlyRole(FACTORY_ROLE) {
        require(
            !categoryCheck[newCategory].exist,
            "YEYE TRAITS: category already exists"
        );
        categories.push(newCategory);
        Category memory newCat = Category(true, (categories.length - 1));
        categoryCheck[newCategory] = newCat;
    }

    function addTrait(uint256 id, string memory category, bool overrides) public onlyRole(FACTORY_ROLE) {
        require(!traits[id].exist, "YEYE TRAITS: trait already exists");
        require(categoryCheck[category].exist, "YEYE TRAITS: category doesn't exists");
        TraitBlueprint memory newTrait = TraitBlueprint(
            true,
            category,
            overrides
        );
        traits[id] = newTrait;
    }

    function setUri(string memory _newUri) public onlyRole(URI_SETTER_ROLE) {
        ERC1155._setURI(_newUri);
    }

    // Override uri
    function uri(uint256 _tokenId) public view override returns (string memory) {
        return string(abi.encodePacked(ERC1155.uri(_tokenId), Strings.toString(_tokenId)));
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data) public onlyRole(MINTER_ROLE) {
        _mint(account, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public onlyRole(MINTER_ROLE) {
        _mintBatch(to, ids, amounts, data);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
        if (from == address(0)) {
            /*
             * @dev check if token with corresponding id is exists
             */
            for (uint256 i; i < ids.length; i++) {
                require(
                    traits[ids[i]].exist, 
                    string(abi.encodePacked("YEYE TRAITS: token ID: ", Strings.toString(ids[i]), " doesn't exists"))
                );
            }
        }
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
