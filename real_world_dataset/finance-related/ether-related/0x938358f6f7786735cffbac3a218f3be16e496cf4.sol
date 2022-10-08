pragma solidity ^0.4.16;

// ----------------------------------------------------------------------------
//
//  HODLwin sale contract
//
//  For details, please visit: https://www.HODLwin.com
//
//  There is a clue to our 5% token giveaway contest in this code  
//  and also a couple of other surprises, good luck
//  Remember to win the prize you and get the remaining clues you
//  must be a token holder and registered for the contest on our
//  webpage. https://www.hodlwin.com
//
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
//
// SafeMath3
//
// Adapted from https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol
// (no need to implement division)
//
// ----------------------------------------------------------------------------

library SafeMath3 {

  function mul(uint a, uint b) internal pure returns (uint c) {
    c = a * b;
    assert(a == 0 || c / a == b);
  }

  function sub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal pure returns (uint c) {
    c = a + b;
    assert(c >= a);
  }

}


// ----------------------------------------------------------------------------
//
// Owned contract
//
// ----------------------------------------------------------------------------

contract Owned {

  address public owner;
  address public newOwner;

  // Events ---------------------------

  event OwnershipTransferProposed(address indexed _from, address indexed _to);
  event OwnershipTransferred(address indexed _from, address indexed _to);

  // Modifier -------------------------

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  // Functions ------------------------

  function Owned() public {
    owner = msg.sender;
  }

  function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != owner);
    require(_newOwner != address(0x0));
    OwnershipTransferProposed(owner, _newOwner);
    newOwner = _newOwner;
  }

  function acceptOwnership() public {
    require(msg.sender == newOwner);
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


// ----------------------------------------------------------------------------
//
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// Clue-1 the password is a quote from a famous person, for more clues
// read the comments in this code carefully, register for the competion for the 
// easier clues on our website www.hodlwin.com, plus keep an eye out for other 
// bounties below.
// ----------------------------------------------------------------------------

contract ERC20Interface {

  // Events ---------------------------

  event Transfer(address indexed _from, address indexed _to, uint _value);
  event Approval(address indexed _owner, address indexed _spender, uint _value);

  // Functions ------------------------

  function totalSupply() public constant returns (uint);
  function balanceOf(address _owner) public constant returns (uint balance);
  function transfer(address _to, uint _value) public returns (bool success);
  function transferFrom(address _from, address _to, uint _value) public returns (bool success);
  function approve(address _spender, uint _value) public returns (bool success);
  function allowance(address _owner, address _spender) public constant returns (uint remaining);

}


// ----------------------------------------------------------------------------
//
// ERC Token Standard #20
//
// ----------------------------------------------------------------------------

contract ERC20Token is ERC20Interface, Owned {
  
  using SafeMath3 for uint;

  uint public tokensIssuedTotal = 0;
  mapping(address => uint) balances;
  mapping(address => mapping (address => uint)) allowed;

  // Functions ------------------------

  /* Total token supply */

  function totalSupply() public constant returns (uint) {
    return tokensIssuedTotal;
  }

  /* Get the account balance for an address */

  function balanceOf(address _owner) public constant returns (uint balance) {
    return balances[_owner];
  }

  /* Transfer the balance from owner's account to another account */

  function transfer(address _to, uint _amount) public returns (bool success) {
    // amount sent cannot exceed balance
    require(balances[msg.sender] >= _amount);

    // update balances
    balances[msg.sender] = balances[msg.sender].sub(_amount);
    balances[_to] = balances[_to].add(_amount);

    // log event
    Transfer(msg.sender, _to, _amount);
    return true;
  }

  /* Allow _spender to withdraw from your account up to _amount */

  function approve(address _spender, uint _amount) public returns (bool success) {
    // approval amount cannot exceed the balance
    require(balances[msg.sender] >= _amount);
      
    // update allowed amount
    allowed[msg.sender][_spender] = _amount;
    
    // log event
    Approval(msg.sender, _spender, _amount);
    return true;
  }

  /* Spender of tokens transfers tokens from the owner's balance */
  /* Must be pre-approved by owner */

  function transferFrom(address _from, address _to, uint _amount) public returns (bool success) {
    // balance checks
    require(balances[_from] >= _amount);
    require(allowed[_from][msg.sender] >= _amount);

    // update balances and allowed amount
    balances[_from] = balances[_from].sub(_amount);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
    balances[_to] = balances[_to].add(_amount);

    // log event
    Transfer(_from, _to, _amount);
    return true;
  }

  /* Returns the amount of tokens approved by the owner */
  /* that can be transferred by spender */

  function allowance(address _owner, address _spender) public constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }

}


// ----------------------------------------------------------------------------
//
// WIN public token sale
//
// ----------------------------------------------------------------------------

contract HODLwin is ERC20Token {

  /* Utility variable */
  
  
  /* Basic token data */

  string public constant name = "HODLwin";
  string public constant symbol = "WIN";
  uint8  public constant decimals = 18;

  /* Wallet addresses - initially set to owner at deployment */
  
  address public wallet;
  address public adminWallet;

  /* ICO dates */

  uint public constant DATE_PRESALE_START = 1518105804; // (GMT): Thursday, 8 February 2018 14:24:58
  uint public constant DATE_PRESALE_END   = 1523019600; // (GMT): Friday, 6 April 2018 13:00:00

  uint public constant DATE_ICO_START = 1523019600; // (GMT): Friday, 6 April 2018 13:00:00
  uint public constant DATE_ICO_END   = 1530882000; // (GMT): Friday, 6 July 2018 13:00:00

  /* ICO tokens per ETH */
  
  uint public tokensPerEth = 1000 * 10**18; // rate during public ICO after bonus period
                                                //-------------------------
  uint public constant BONUS_PRESALE      = 50;// Clue-2 pyethrecover may 
  uint public constant BONUS_ICO_PERIOD_ONE = 20;// be useful once you receive
  uint public constant BONUS_ICO_PERIOD_TWO = 10;// further clues                
                                                //-------------------------
  /* Other ICO parameters */  
  
  uint public constant TOKEN_SUPPLY_TOTAL = 100000000 * 10**18; // 100 mm tokens
  uint public constant TOKEN_SUPPLY_ICO   = 50000000 * 10**18; // 50 mm tokens avalibale for presale and public
  uint public constant TOKEN_SUPPLY_AIR   = 50000000 * 10**18; //  50 mm tokens, all team tokens, airdrop, bounties will be sent publicly using this so everything is transparent

  uint public constant PRESALE_ETH_CAP =  10000 ether;

  uint public constant MIN_FUNDING_GOAL =  100 * 10**18 ; //
  
  uint public constant MIN_CONTRIBUTION = 1 ether / 20; // 0.05 Ether
  uint public constant MAX_CONTRIBUTION = 10000 ether;

  uint public constant COOLDOWN_PERIOD =  1 days;
  uint public constant CLAWBACK_PERIOD = 90 days;

  /* Crowdsale variables */

  uint public icoEtherReceived = 0; // Ether actually received by the contract

  uint public tokensIssuedIco   = 0;
  uint public tokensIssuedAir   = 0;
  

  /* Keep track of Ether contributed and tokens received during Crowdsale */
  
  mapping(address => uint) public icoEtherContributed;
  mapping(address => uint) public icoTokensReceived;

  /* Keep track of participants who 
   /* have reclaimed their contributions in case of failed Crowdsale */

   mapping(address => bool) public refundClaimed;
 

  // Events ---------------------------
  
  event WalletUpdated(address _newWallet);
  event AdminWalletUpdated(address _newAdminWallet);
  event TokensPerEthUpdated(uint _tokensPerEth);
  event TokensMinted(address indexed _owner, uint _tokens, uint _balance);
  event TokensIssued(address indexed _owner, uint _tokens, uint _balance, uint _etherContributed);
  event Refund(address indexed _owner, uint _amount, uint _tokens);
 

  // Basic Functions ------------------

  /* Initialize (owner is set to msg.sender by Owned.Owned() */

  function HODLwin () public {
    require(TOKEN_SUPPLY_ICO + TOKEN_SUPPLY_AIR == TOKEN_SUPPLY_TOTAL);
    wallet = owner;
    adminWallet = owner;
  }

  /* Fallback */
  
  function () public payable {
    buyTokens();
  }
  
  // Information functions ------------
  
  /* What time is it? */
  
  function atNow() public constant returns (uint) {
    return now;
  }
  
  /* Has the minimum threshold been reached? */
  
  function icoThresholdReached() public constant returns (bool thresholdReached) {
     if (icoEtherReceived < MIN_FUNDING_GOAL) {
        return false; 
     }
     return true;
  }  
  
  /* Are tokens transferable? */

  function isTransferable() public constant returns (bool transferable) {
     if (!icoThresholdReached()) { 
         return false;
         }
     if (atNow() < DATE_ICO_END + COOLDOWN_PERIOD) {
          return false; 
          }
     return true;
  }
  
  // Owner Functions ------------------
  
  /* Change the crowdsale wallet address */

  function setWallet(address _wallet) public onlyOwner {
    require(_wallet != address(0x0));
    wallet = _wallet;
    WalletUpdated(wallet);
  }

  /* Change the admin wallet address */

  function setAdminWallet(address _wallet) public onlyOwner {
    require(_wallet != address(0x0));
    adminWallet = _wallet;
    AdminWalletUpdated(adminWallet);
  }

  /* Change tokensPerEth before ICO start */
  
  function updateTokensPerEth(uint _tokensPerEth) public onlyOwner {
    require(atNow() < DATE_PRESALE_START);
    tokensPerEth = _tokensPerEth;
    TokensPerEthUpdated(_tokensPerEth);
  }

  /* Minting of airdrop tokens by owner */

  function mintAirdrop(address _participant, uint _tokens) public onlyOwner {
    // check amount
    require(_tokens <= TOKEN_SUPPLY_AIR.sub(tokensIssuedAir));
    require(_tokens.mul(10) <= TOKEN_SUPPLY_AIR);//to prevent mistakenly sending too many tokens to one address in airdrop
    // update balances
    balances[_participant] = balances[_participant].add(_tokens);
    tokensIssuedAir = tokensIssuedAir.add(_tokens);
    tokensIssuedTotal = tokensIssuedTotal.add(_tokens);

    // log the miniting
    Transfer(0x0, _participant, _tokens);
    TokensMinted(_participant, _tokens, balances[_participant]);
  }

function mintMultiple(address[] _addresses, uint _tokens) public onlyOwner {
    require(msg.sender == adminWallet);
    require(_tokens.mul(10) <= TOKEN_SUPPLY_AIR);//to prevent mistakenly sending all tokens to one address in airdrop
    for (uint i = 0; i < _addresses.length; i++) {
     mintAirdrop(_addresses[i], _tokens);
        }
    
  }  
  
  /* Owner clawback of remaining funds after clawback period */
  /* (for use in case of a failed Crwodsale) */
  
  function ownerClawback() external onlyOwner {
    require(atNow() > DATE_ICO_END + CLAWBACK_PERIOD);
    wallet.transfer(this.balance);
  }

  /* Transfer out any accidentally sent ERC20 tokens */

  function transferAnyERC20Token(address tokenAddress, uint amount) public onlyOwner returns (bool success) {
      return ERC20Interface(tokenAddress).transfer(owner, amount);
  }

  // Private functions ----------------

//caspsareimportant
//---------------------------------------------------------------------
// the first PeRson to send an email to hodlwin at (