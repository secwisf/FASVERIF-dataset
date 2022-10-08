pragma solidity ^0.4.15;

/// @title SafeMath
/// @dev Math operations with safety checks that throw on error
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns(uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns(uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns(uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns(uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


/// @title Ownable
/// @dev The Ownable contract has an owner address, and provides basic authorization control
/// functions, this simplifies the implementation of "user permissions".
contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /// @dev The Ownable constructor sets the original `owner` of the contract to the sender
  /// account.
  function Ownable() public {
    owner = msg.sender;
  }

  /// @dev Throws if called by any account other than the owner.
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /// @dev Allows the current owner to transfer control of the contract to a newOwner.
  /// @param newOwner The address to transfer ownership to.
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}


/// @title Pausable
/// @dev Base contract which allows children to implement an emergency stop mechanism.
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;

  /// @dev Modifier to make a function callable only when the contract is not paused.
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /// @dev Modifier to make a function callable only when the contract is paused.
  modifier whenPaused() {
    require(paused);
    _;
  }

  /// @dev called by the owner to pause, triggers stopped state
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /// @dev called by the owner to unpause, returns to normal state
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}


/// @title The interface to execute the tokenFallback
/// @author Merunas Grincalaitis <