// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "contracts/YeyeBase.sol";

contract ListedMint {
    bytes32 public immutable merkleRoot;
    uint256 public immutable tokenID;

    address public immutable tokenContract;
    uint public immutable tokenPrice;

    constructor(bytes32 _merkleRoot, uint256 _tokenID, address _tokenContract, uint _tokenPrice) {
        merkleRoot = _merkleRoot;
        tokenID = _tokenID;
        tokenContract = _tokenContract;
        tokenPrice = _tokenPrice;
    }

    function toBytes32(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }

    function mint(bytes32[] calldata merkleProof, uint256 amount) public payable {
        require(msg.value >= (tokenPrice * amount), "Not enough ethers");
        require(MerkleProof.verify(merkleProof, merkleRoot, toBytes32(msg.sender)) == true, "invalid proof");
        YeyeBase mintContract = YeyeBase(tokenContract);
        mintContract.mint(msg.sender, tokenID, amount, "0x00");
    }
}
