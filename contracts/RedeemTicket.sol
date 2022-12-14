// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./YeyeBase.sol";
import "./YeyeTrait.sol";

contract RedeemTicket is Ownable {
    // stores price for certain level
    struct LevelData {
        bool exist;
        uint price;
    }
    // list of levels
    uint[] levels;
    // mapping from level to LevelData
    mapping(uint => LevelData) public levelData;
    // mapping from Token ID to level
    mapping(uint256 => uint) public traitLevel;
    mapping(uint256 => uint) public baseLevel;

    struct GetResult {
        uint256 id;
        uint level;
        uint price;
    }
    struct SetResult {
        uint256 id;
        uint level;
    }

    struct GetSetLevel {
        uint level;
        uint price;
    }

    // NFT List
    uint256[] public bases;
    uint256[] public traits;

    // mapping quota for each address
    mapping(address => uint) public quota;
    // mapping quota used for each address
    mapping(address => uint) public used;

    // sale state
    uint private closedIn;
    bool public paused;

    // stores withdraw address
    address payable private withdrawAddress;

    // stores base NFT Contract Address
    address public baseAddress;
    // stores trait NFT Contract Address
    address public traitAddress;
    // stores list of Token ID wich is ticket NFT
    uint[] public tickets;
    
    constructor(address _baseAddress, address _traitAddress) {
        baseAddress = _baseAddress;
        traitAddress = _traitAddress;
    }
    
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

    /*
    * @dev modifier to check if sender have any tickets
    */
    modifier hasTicket(address account) {
        YeyeBase base = YeyeBase(baseAddress);
        uint256[] memory ids = tickets;
        uint ticketCount;
        for (uint i = 0; i < ids.length; i++)
        {
            ticketCount += base.balanceOf(account, ids[i]);
        }
        require(ticketCount > 0, "REDEEM: You don't have any ticket");
        _;
    }

    function setLevel(GetSetLevel[] calldata data) public onlyOwner {
        
    }

    function setBase(SetResult[] calldata data) public onlyOwner {
        YeyeBase baseContract = YeyeBase(baseAddress);
        for (uint i = 0; i < data.length; i++) 
        {
            (bool exist,,) = baseContract.tokenCheck(data[i].id);
            require(exist, string(abi.encodePacked("REDEEM: Token with ID: ", Strings.toString(data[i].id), " doesn't exist")));
            require(levelData[data[i].level].exist, string(abi.encodePacked("REDEEM: Level data: ", Strings.toString(data[i].level), " doesn't exist")));
            baseLevel[data[i].id] = data[i].level;
            bases.push(data[i].id);
        }
    }

    function getBase() public view returns (GetResult[] memory) {
        uint256[] memory data = bases;
        GetResult[] memory result = new GetResult[](data.length);
        for (uint i = 0; i < data.length; i++) 
        {
            result[i].id = data[i];
            result[i].level = baseLevel[data[i]];
            result[i].price = levelData[baseLevel[data[i]]].price;
        }
        return result;
    }

    function setTickets(uint256[] calldata _tickets) public isClosed {
        checkTicket(_tickets, baseAddress);
        tickets = _tickets;
    }

    function setBaseContract(address _newAddress) public onlyOwner isClosed {
        baseAddress = _newAddress;
    }

    function setTraitContract(address _newAddress) public onlyOwner isClosed {
        traitAddress = _newAddress;
    }

    function setWithdrawAddress(address newAddress) public onlyOwner {
        withdrawAddress = payable(newAddress);
    }

    /*
    * @dev redeem ticket and get mint quota
    */
    function redeem() public isNotClosed isNotPaused hasTicket(_msgSender()) {
        YeyeBase base = YeyeBase(baseAddress);
        uint ticketCount;
        uint[] memory tokenIds = tickets;
        uint[] memory values = new uint[](tokenIds.length);

        for (uint i = 0; i < tokenIds.length; i++) 
        {
            values[i] = base.balanceOf(_msgSender(), tokenIds[i]);
            ticketCount += values[i];
        }

        base.factoryBurnBatch(_msgSender(), tokenIds, values);
        quota[_msgSender()] = ticketCount;
    }
    
    /*
    * @dev mint and equip NFT
    */
    function mint(uint256 _id, uint256 _base, uint256[] memory traits) public payable isNotClosed isNotPaused {
        YeyeBase baseContract = YeyeBase(baseAddress);
        (bool exist, bool redeemable, bool equipable) = baseContract.tokenCheck(_base);
        (bool yExist,) = baseContract.equippedToken(_base);
        if (exist && (!equipable || !redeemable)) {
            require(traits.length == 0, "");
            baseContract.mint(_msgSender(), _base, 1, "0x00");
            return;
        } else if (exist && equipable) {
            // do the equip shit
        }
        YeyeTrait traitContract = YeyeTrait(traitAddress);
        uint total;
        for (uint i = 0; i < traits.length; i++) 
        {
            total += levelData[traitLevel[traits[i]]].price;
        }
        require(msg.value >= total, "Not enough ether");
        /*
        TODO:
        1. sum price
        2. check if msg.value is sufficient
        3. check each trait quality (noramal, rare, legend, etc)
        4. mint base and each trait
        5. do the equip proccess
        */
    }

    /*
    * @dev function to check if ticket is the right type NFT
    */
    function checkTicket(uint256[] calldata _tickets, address _contractAddress) private view {
        YeyeBase base = YeyeBase(_contractAddress);
        for (uint i = 0; i < _tickets.length; i++)
        {
            (bool exist, bool redeemable, bool equipable) = base.tokenCheck(_tickets[i]);
            require(exist, string(abi.encodePacked("REDEEM: Token with ID: ", Strings.toString(_tickets[i]), " doesn't exist")));
            require(redeemable && !equipable, string(abi.encodePacked("REDEEM: Invalid token type. ID: ", Strings.toString(_tickets[i]))));
        }
    }

    /*
    * @dev Transfer funds to withdraw address
    */
    function withdraw() public onlyOwner {
        require(withdrawAddress != address(0), "Cannot withdraw to Address Zero");
        withdrawAddress.transfer(address(this).balance);
    }

    /*
    * @dev Transfer funds to withdraw address then destroy the contract (IRREVERSIBLE)
    */
    function destroyContract() public onlyOwner isClosed {
        require(withdrawAddress != address(0), "Cannot withdraw to Address Zero");
        selfdestruct(withdrawAddress);
    }
}