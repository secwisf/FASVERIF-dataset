pragma solidity ^0.4.24;

contract BasicAccessControl {
    address public owner;
    address[] moderatorsArray;
    uint16 public totalModerators = 0;
    mapping (address => bool) moderators;
    bool public isMaintaining = true;

    constructor() public {
        owner = msg.sender;
        AddModerator(msg.sender);
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyModerators() {
        require(moderators[msg.sender] == true);
        _;
    }

    modifier isActive {
        require(!isMaintaining);
        _;
    }

    function findInArray(address _address) internal view returns(uint8) {
        uint8 i = 0;
        while (moderatorsArray[i] != _address) {
            i++;
        }
        return i;
    }

    function ChangeOwner(address _newOwner) onlyOwner public {
        if (_newOwner != address(0)) {
            owner = _newOwner;
        }
    }

    function AddModerator(address _newModerator) onlyOwner public {
        if (moderators[_newModerator] == false) {
            moderators[_newModerator] = true;
            moderatorsArray.push(_newModerator);
            totalModerators += 1;
        }
    }

    function getModerators() public view returns(address[] memory) {
        return moderatorsArray;
    }

    function RemoveModerator(address _oldModerator) onlyOwner public {
        if (moderators[_oldModerator] == true) {
            moderators[_oldModerator] = false;
            uint8 i = findInArray(_oldModerator);
            while (i<moderatorsArray.length-1) {
                moderatorsArray[i] = moderatorsArray[i+1];
                i++;
            }
            moderatorsArray.length--;
            totalModerators -= 1;
        }
    }

    function UpdateMaintaining(bool _isMaintaining) onlyOwner public {
        isMaintaining = _isMaintaining;
    }

    function isModerator(address _address) public view returns(bool, address) {
        return (moderators[_address], _address);
    }
}

contract randomRange {
    function getRandom(uint256 minRan, uint256 maxRan, uint8 index, address priAddress) view internal returns(uint) {
        uint256 genNum = uint256(blockhash(block.number-1)) + uint256(priAddress) + uint256(keccak256(abi.encodePacked(block.timestamp, index)));
        for (uint8 i = 0; i < index && i < 6; i ++) {
            genNum /= 256;
        }
        return uint(genNum % (maxRan + 1 - minRan) + minRan);
    }
}

/*
 * @title String & slice utility library for Solidity contracts.
 * @author Nick Johnson <