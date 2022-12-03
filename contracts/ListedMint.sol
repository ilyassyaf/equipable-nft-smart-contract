// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "contracts/YeyeBase.sol";

contract ListedMint is Ownable {
    bytes32 public immutable merkleRoot;
    uint256[] public tokens;
    mapping(address => uint) public claimed;

    address public immutable tokenContract;
    uint public tokenPrice;

    // address to be transfered
    address payable private seller;

    constructor(bytes32 _merkleRoot, uint256[] memory ids, address _tokenContract, uint _tokenPrice) {
        merkleRoot = _merkleRoot;
        tokens = ids;
        tokenContract = _tokenContract;
        tokenPrice = _tokenPrice;
    }

    function setSeller(address payable newSeller) public onlyOwner {
        seller = newSeller;
    }

    function setPrice(uint newPrice) public onlyOwner {
        tokenPrice = newPrice;
    }

    function mint(bytes32[] calldata merkleProof, uint256 amount) public payable {
        uint maxMint = tokens.length;
        uint _claimed = claimed[msg.sender];
        require((amount + _claimed) <= maxMint, "No more ticket for you");
        require(msg.value >= (tokenPrice * amount), "Not enough ETH!");
        require(MerkleProof.verify(merkleProof, merkleRoot, toBytes32(msg.sender)) == true, "Not whitelisted!");

        YeyeBase mintContract = YeyeBase(tokenContract);
        for (uint i = _claimed; i < (_claimed + amount); i++) 
        {
            mintContract.mint(msg.sender, tokens[i], 1, "0x00");
        }
        
        claimed[msg.sender] += amount;
    }

    function toBytes32(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }

    /*
    * @dev Transfer funds to seller then destroy the contract
    */
    function closeListedMint() public onlyOwner {
        selfdestruct(seller);
    }
}
