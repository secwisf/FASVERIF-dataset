pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/access/rbac/Roles.sol

/**
 * @title Roles
 * @author Francisco Giordano (@frangio)
 * @dev Library for managing addresses assigned to a Role.
 * See RBAC.sol for example usage.
 */
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  /**
   * @dev give an address access to this role
   */
  function add(Role storage _role, address _addr)
    internal
  {
    _role.bearer[_addr] = true;
  }

  /**
   * @dev remove an address' access to this role
   */
  function remove(Role storage _role, address _addr)
    internal
  {
    _role.bearer[_addr] = false;
  }

  /**
   * @dev check if an address has this role
   * // reverts
   */
  function check(Role storage _role, address _addr)
    internal
    view
  {
    require(has(_role, _addr));
  }

  /**
   * @dev check if an address has this role
   * @return bool
   */
  function has(Role storage _role, address _addr)
    internal
    view
    returns (bool)
  {
    return _role.bearer[_addr];
  }
}

// File: contracts/v2/AccessControl.sol

/**
 * @title Based on OpenZeppelin Whitelist & RBCA contracts
 * @dev The AccessControl contract provides different access for addresses, and provides basic authorization control functions.
 */
contract AccessControl {

  using Roles for Roles.Role;

  uint8 public constant ROLE_KNOWN_ORIGIN = 1;
  uint8 public constant ROLE_MINTER = 2;
  uint8 public constant ROLE_UNDER_MINTER = 3;

  event RoleAdded(address indexed operator, uint8 role);
  event RoleRemoved(address indexed operator, uint8 role);

  address public owner;

  mapping(uint8 => Roles.Role) private roles;

  modifier onlyIfKnownOrigin() {
    require(msg.sender == owner || hasRole(msg.sender, ROLE_KNOWN_ORIGIN));
    _;
  }

  modifier onlyIfMinter() {
    require(msg.sender == owner || hasRole(msg.sender, ROLE_KNOWN_ORIGIN) || hasRole(msg.sender, ROLE_MINTER));
    _;
  }

  modifier onlyIfUnderMinter() {
    require(msg.sender == owner || hasRole(msg.sender, ROLE_KNOWN_ORIGIN) || hasRole(msg.sender, ROLE_UNDER_MINTER));
    _;
  }

  constructor() public {
    owner = msg.sender;
  }

  ////////////////////////////////////
  // Whitelist/RBCA Derived Methods //
  ////////////////////////////////////

  function addAddressToAccessControl(address _operator, uint8 _role)
  public
  onlyIfKnownOrigin
  {
    roles[_role].add(_operator);
    emit RoleAdded(_operator, _role);
  }

  function removeAddressFromAccessControl(address _operator, uint8 _role)
  public
  onlyIfKnownOrigin
  {
    roles[_role].remove(_operator);
    emit RoleRemoved(_operator, _role);
  }

  function checkRole(address _operator, uint8 _role)
  public
  view
  {
    roles[_role].check(_operator);
  }

  function hasRole(address _operator, uint8 _role)
  public
  view
  returns (bool)
  {
    return roles[_role].has(_operator);
  }

}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: openzeppelin-solidity/contracts/ownership/HasNoEther.sol

/**
 * @title Contracts that should not own Ether
 * @author Remco Bloemen <