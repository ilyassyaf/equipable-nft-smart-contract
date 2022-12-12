// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "contracts/YeyeBase.sol";

contract ListedMint is Ownable {
    // Merkle Root
    bytes32 public merkleRoot;
    // list of token ID to mint, make sure the ID is exist 
    uint256[] public tokens;
    // count claimed token per address
    mapping(uint => mapping(address => uint)) public claimed;
    // contract of token to be minted
    address public tokenContract;
    // token price
    uint public tokenPrice;
    // address to be transfered after the sale ends
    address payable private withdrawAddress;

    // mint sale state
    uint public batch;
    bool public paused;
    uint private closedIn;

    // modifier
    modifier isNotClosed {
        require(block.timestamp <= closedIn, "Mint is over");
        _;
    }
    modifier isClosed {
        require(block.timestamp > closedIn, "Mint is not over yet");
        _;
    }
    modifier isPaused {
        require(paused, "Mint is not paused");
        _;
    }
    modifier isNotPaused {
        require(!paused, "Mint is paused");
        _;
    }

    constructor() {
        withdrawAddress = payable(_msgSender());
    }

    /*
    * @dev pause Mint in case of emergency
    */
    function pause() public onlyOwner isNotClosed isNotPaused {
        paused = true;
    }

    /*
    * @dev unpause Mint in case of emergency
    */
    function unpause() public onlyOwner isNotClosed isPaused {
        paused = false;
    }

    /*
    * @dev set seller address
    */
    function setWithdrawAddress(address payable newWithdrawAddress) public onlyOwner {
        withdrawAddress = newWithdrawAddress;
    }

    /*
    * @dev set Merkle Root in case of emergency pause
    */
    function setMerkleRoot(bytes32 newRoot) public onlyOwner isClosed {
        merkleRoot = newRoot;
    }

    /*
    * @dev set Token Contract in case of emergency pause
    */
    function setTokenContract(address newAddress) public onlyOwner isClosed {
        tokenContract = newAddress;
    }

    /*
    * @dev set Token to sell in case of emergency pause
    */
    function setToken(uint256[] memory newIds) public onlyOwner isClosed {
        tokens = newIds;
    }

    /*
    * @dev set NFT price in case of emergency pause
    */
    function setPrice(uint newPrice) public onlyOwner isClosed {
        tokenPrice = newPrice;
    }

    /*
    * @dev add more time to extend sale duration
    */
    function addTime(uint hour) public onlyOwner isNotClosed {
        closedIn += (hour * 1 hours);
    }

    /*
    * @dev get time left of the current sale
    */
    function getTimeLeft() public view isNotClosed returns (uint _timeLeft) {
        _timeLeft = closedIn - block.timestamp;
    }

    /*
    * @dev listed mint function
    */
    function mint(bytes32[] calldata merkleProof, uint256 amount) public payable isNotClosed isNotPaused {
        require(MerkleProof.verify(merkleProof, merkleRoot, toBytes32(_msgSender())) == true, "Not whitelisted!");
        require(msg.value >= (tokenPrice * amount), "Not enough ETH!");
        uint maxMint = tokens.length;
        uint _claimed = claimed[batch][_msgSender()];
        require((amount + _claimed) <= maxMint, "No more ticket for you");

        YeyeBase mintContract = YeyeBase(tokenContract);
        for (uint i = _claimed; i < (_claimed + amount); i++) 
        {
            mintContract.mint(_msgSender(), tokens[i], 1, "0x00");
        }
        
        claimed[batch][_msgSender()] += amount;
    }

    /*
    * @dev Start new Mint Sale
    * Param :
    * - newRoot     = New Merkle Root
    * - ids         = List of token id (ids.length = max mint, so each address can buy one per NFT)
    * - tokenAddr   = Contract address of token
    * - price       = Token Price
    * - duration    = Duration of the sale (in hours)
    */
    function startNew(bytes32 newRoot, uint256[] calldata ids, address tokenAddr, uint price, uint duration) public onlyOwner isClosed {
        merkleRoot = newRoot;
        tokens = ids;
        tokenContract = tokenAddr;
        tokenPrice = price;

        batch += 1;
        closedIn = block.timestamp + (duration * 1 hours);
    }

    /*
    * @dev Transfer funds to withdraw address
    */
    function withdraw() public onlyOwner {
        require(withdrawAddress != address(0), "Cannot withdraw to Address Zero");
        withdrawAddress.transfer(address(this).balance);
    }

    /*
    * @dev address to Bytes32 helper
    */
    function toBytes32(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }

    /*
    * @dev Transfer funds to withdraw address then destroy the contract (IRREVERSIBLE)
    */
    function destroyContract() public onlyOwner isClosed {
        require(withdrawAddress != address(0), "Cannot withdraw to Address Zero");
        selfdestruct(withdrawAddress);
    }
}
