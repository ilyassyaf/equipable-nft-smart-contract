// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./ERC1155Burnable.sol";
import "./ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract YeyeBase is ERC1155, AccessControl, ERC1155Burnable, ERC1155Supply {
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant VAULT_ROLE = keccak256("VAULT_ROLE");
    bytes32 public constant FACTORY_ROLE = keccak256("FACTORY_ROLE");

    string public name = "YEYE Factory";

    // Base Blueprint
    struct TokenBlueprint {
        bool exist; // check if trait exist
        bool redeemable; // check if token redeemable
        bool isEquipped; // check if Base NFT or Equipped NFT
    }
    mapping(uint256 => TokenBlueprint) public tokenCheck;

    // Equipped Token Blueprint
    struct YeyeBlueprint {
        bool exist;
        uint256 base;
        string[] cats;
        uint256[] traits;
    }
    mapping(uint256 => YeyeBlueprint) public equippedToken;

    constructor(string memory _uri) ERC1155(_uri) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(URI_SETTER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(FACTORY_ROLE, msg.sender);
    }

    function addBase(uint256 newId) external onlyRole(FACTORY_ROLE) {
        require(
            !tokenCheck[newId].exist,
            string(abi.encodePacked("YEYE: token ID: ", Strings.toString(newId), " already exists"))
        );

        TokenBlueprint memory newCheck = TokenBlueprint(true, false, false);
        tokenCheck[newId] = newCheck;
    }

    function addRedeemable(uint256 newId) external onlyRole(FACTORY_ROLE) {
        require(
            !tokenCheck[newId].exist,
            string(abi.encodePacked("YEYE: token ID: ", Strings.toString(newId), " already exists"))
        );

        TokenBlueprint memory newCheck = TokenBlueprint(true, true, false);
        tokenCheck[newId] = newCheck;
    }

    function addEquipped(uint256 newId, YeyeBlueprint memory newToken) external onlyRole(FACTORY_ROLE) {
        require(
            !tokenCheck[newId].exist,
            string(abi.encodePacked("YEYE: token ID: ", Strings.toString(newId), " already exists"))
        );

        equippedToken[newId] = newToken;
        TokenBlueprint memory newCheck = TokenBlueprint(true, false, true);
        tokenCheck[newId] = newCheck;
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

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal override(ERC1155, ERC1155Supply) {
        /*
         * @dev check if token with corresponding id is exists
         */
        for (uint256 i; i < ids.length; i++) {
            require(
                tokenCheck[ids[i]].exist,
                string(abi.encodePacked("YEYE TRAITS: token ID: ", Strings.toString(ids[i]), " doesn't exists"))
            );
        }
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
