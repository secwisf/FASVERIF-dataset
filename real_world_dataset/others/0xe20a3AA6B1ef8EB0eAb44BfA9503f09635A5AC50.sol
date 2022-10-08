pragma solidity ^0.4.25;

/*  
     ==================================================================
    ||  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  ||
    ||  + Digital Multi Level Marketing in Ethereum smart-contract +  ||
    ||  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  ||
     ==================================================================
     
    https://ethmlm.com
    https://t.me/ethmlm
    
    
         ``..................``  ``....................``  ``..``             ``.``          
        `..,,,,,,,,,,,,,,,,,,.` ``.,,,,,,,,,,,,,,,,,,,,.`  `.,,.`            `..,.``         
        `.:::::,,,,,,,,,,,,,,.```.,,,,,,,:::::::,,,,,,,.`  `,::,.            `.,:,.`         
        `,:;:,,...............`  `.......,,:;::,,.......`  .,::,.`           `.:;,.`         
        `,:;:,.```````````````   ````````.,:::,.````````   .,::,.`           `.:;,.`         
     ++++++++++++++++++++    ++++++++++++++++++++++,   ,+++.,::,.`        ++++.:;,.`         
     ####################    ######################:   ,###.,::,.`        ####.:;,.`         
     ###';'';;:::::::::::````:::::::::+###;;'';::::.   ,###.,::,.`````````####,:;,.`         
     ###;,:;:,,.............``        +###.,::,`       ,###.,:;:,,........####::;,.`         
     ###;,:;:::,,,,,,,,,,,,,.`        +###.,::,`       ,###.,:;::,,,,,,,,,####::;,.`         
     ###;,:;::,,,,,,,,,,,,,,.`        +###.,::,`       ,###.,:;::,,,,,,,,,####::;,.`         
     ###;,:;:,..............``        +###.,::,`       ,###.,:::,.````````####,:;,.`         
     ###;,:;:.``````````````          +###.,::,`       ,###.,::,.`        ####,:;,.`         
     ###################              +###.,::,`       ,######################.:;,.`         
     ###################              +###.,::,`       ,######################.:;,.`         
     ###;,:;:.````````````````        +###.,::,`       ,###.,::,.`        ####.:;,.`         
     ###;,:;:,................``      +###.,::,`       ,###.,::,.`        ####.:;,.`         
     ###;,:;:::,,,,,,,,,,,,,,,.`      +###.,::,`       ,###.,::,.`        ####.:;,.`         
     ###:.,,,,,,,,,,,,,,,,,,,,.`      +###`.,,.`       ,###`.,,.`         ####.,,,.`         
     ###:`....................``      +###``..``       ,###``..``         ####`...`          
     ###: `````````````````````       +### ````        ,### ````          #### ```           
     #####################            +###             ,###               ####               
     #####################            +###             ,###               ####               
     ,,,,,,,,,,,,,,,,,,,,,     `````` .,,,`````        `,,,     ```````   ,,,,        `````` 
        `..,,,.``             `..,,.``   ``.,.`                `..,,,.``             `..,,.``
        `.::::,.`            `.,:::,.`   `.,:,.`               `.,:::,.`            `.,:::,.`
        .,:;;;:,.`           .,:;;;:.`   `,:;,.`               .,:;;;:,.`           .,:;;;:,`
        .,:;::::,`          `.,:;;;:.`   `,:;,.`               .,:;::::,`          `.,:::;:,`
        .,::::::,.`        `.,::::;:.`   `,:;,.`               .,:;::::,.`        `.,::::;:,`
    .#####+::,,::,`       ######::;:.,###`,:;,.`            ######::::::,`       +#####::;:,`
    .######:,,,::,.`      ######,:;:.,###`,:;,.`            ######:,,,::,.`      ######,,;:,`
    .######+,..,::,`     #######,:;:.,###`,:;,.`            ###'###,..,::,`     #######.,;:,`
    .###.###,.`.,:,.`   .##+####.:;:.,###`,:;,.`            ###.###,.`.,:,.`    #######.,;:,`
    .###.+###.``,::,`   ###:####.:;:.,###`,:;,.`            ###.'###.`.,::,`   ###:####.,;:,`
    .###.,###. `.,:,.` :##':####.:;:.,###`,:;,.`            ###.,###,``.,:,.` `##+:####.,;:,`
    .###.,+###  `,::,.`###:,####.:;:.,###`,:;,.`            ###.,'###` `,::,. ###:,####.,;:,`
    .###.,:###` `.,::.'##;:,####.:;:.,###`,:;,.`            ###.,:###, `.,::.,##':,####.,;:,`
    .###.,:'###  `,::,###:,.####.:;:.,###`,:;,.`            ###.,:;###  `,::,###:,.####.,;:,`
    .###.,::###` `.,:+##::,`####.:;:.,###`,:;,.`            ###.,::###: `.,:'##;:,`####.,;:,`
    .###.,::;###  `,:###:,.`####.:;:.,###`,:;:,............`###.,::,###  `,:###:,.`####.,;:,`
    .###.,::,###. `.###::,` ####.:;:.,###`,:;::,,,,,,,,,,,,.###.,::,###; `.+##;:,` ####.,;:,`
    .###`.::.,###  `##+:,.` ####.,:,.,###`.,:::,,,,,,,,,,,,.###`.,:,.###  `###:,.` ####.,:,.`
    .###`....`###, ###,..`  ####`.,.`,###``.,,,,,,,,,,,,,,..###`....`###' +##,..`  ####`.,.``
    .### ```` `###`##'```   ####`````,### ``````````````````### ````  ### ##+```   ####````` 
    .###       ######       ####     .###                   ###       +#####       ####      
    .###        ####,       ####     .#################     ###        ####'       ####      
    .###        ####        ####     .#################     ###        '###        ####     
    

*/

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}
/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}
/**
 * Utility library of inline functions on addresses
 */
library Address {

  /**
   * Returns whether the target address is a contract
   * @dev This function will return false if invoked during the constructor of a contract,
   * as the code is not actually created until after the constructor finishes.
   * @param account address of the account to check
   * @return whether the target address is a contract
   */
  function isContract(address account) internal view returns (bool) {
    uint256 size;
    // XXX Currently there is no better way to check if there is a contract in an address
    // than to check the size of the code at that address.
    // See https://ethereum.stackexchange.com/a/14016/36603
    // for more details about how this works.
    // TODO Check this again before the Serenity release, because all addresses will be
    // contracts then.
    // solium-disable-next-line security/no-inline-assembly
    assembly { size := extcodesize(account) }
    return size > 0;
  }

}
/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <