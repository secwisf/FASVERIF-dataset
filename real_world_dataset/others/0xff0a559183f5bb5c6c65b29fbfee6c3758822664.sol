pragma solidity 0.4.24;


/**
 * @title SafeMath
 * @notice Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @notice Multiplies two numbers, throws on overflow.
  * @param a Multiplier
  * @param b Multiplicand
  * @return {"result" : "Returns product"}
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 result) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b, "Error: Unsafe multiplication operation!");
    return c;
  }

  /**
  * @notice Integer division of two numbers, truncating the quotient.
  * @param a Dividend
  * @param b Divisor
  * @return {"result" : "Returns quotient"}
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256 result) {
    // @dev require(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // @dev require(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @notice Subtracts two numbers, throws on underflow.
  * @param a Subtrahend
  * @param b Minuend
  * @return {"result" : "Returns difference"}
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256 result) {
    // @dev throws on overflow (i.e. if subtrahend is greater than minuend)
    require(b <= a, "Error: Unsafe subtraction operation!");
    return a - b;
  }

  /**
  * @notice Adds two numbers, throws on overflow.
  * @param a First addend
  * @param b Second addend
  * @return {"result" : "Returns summation"}
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 result) {
    uint256 c = a + b;
    require(c >= a, "Error: Unsafe addition operation!");
    return c;
  }
}


/**

COPYRIGHT 2018 Token, Inc.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


@title Ownable
@dev The Ownable contract has an owner address, and provides basic authorization control
functions, this simplifies the implementation of "user permissions".


 */
contract Ownable {

  mapping(address => bool) public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  event AllowOwnership(address indexed allowedAddress);
  event RevokeOwnership(address indexed allowedAddress);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner[msg.sender] = true;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(owner[msg.sender], "Error: Transaction sender is not allowed by the contract.");
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   * @return {"success" : "Returns true when successfully transferred ownership"}
   */
  function transferOwnership(address newOwner) public onlyOwner returns (bool success) {
    require(newOwner != address(0), "Error: newOwner cannot be null!");
    emit OwnershipTransferred(msg.sender, newOwner);
    owner[newOwner] = true;
    owner[msg.sender] = false;
    return true;
  }

  /**
   * @dev Allows interface contracts and accounts to access contract methods (e.g. Storage contract)
   * @param allowedAddress The address of new owner
   * @return {"success" : "Returns true when successfully allowed ownership"}
   */
  function allowOwnership(address allowedAddress) public onlyOwner returns (bool success) {
    owner[allowedAddress] = true;
    emit AllowOwnership(allowedAddress);
    return true;
  }

  /**
   * @dev Disallows interface contracts and accounts to access contract methods (e.g. Storage contract)
   * @param allowedAddress The address to disallow ownership
   * @return {"success" : "Returns true when successfully allowed ownership"}
   */
  function removeOwnership(address allowedAddress) public onlyOwner returns (bool success) {
    owner[allowedAddress] = false;
    emit RevokeOwnership(allowedAddress);
    return true;
  }

}

/**

COPYRIGHT 2018 Token, Inc.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


@title TokenIOStorage - Serves as derived contract for TokenIO contract and
is used to upgrade interfaces in the event of deprecating the main contract.

@author Ryan Tate <