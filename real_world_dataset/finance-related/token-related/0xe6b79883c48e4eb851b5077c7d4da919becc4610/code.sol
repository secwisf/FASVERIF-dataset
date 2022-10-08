/**
 *Submitted for verification at Etherscan.io on 2022-02-08
*/

/**
 *Submitted for verification at Etherscan.io on 2021-12-14
*/

pragma solidity >=0.4.21 <0.6.0;

interface ERC20 {
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract YahtsContract is ERC20 {
    string  internal _name              = "VI YAHTS 1";
    string  internal _symbol            = "VT1";
    string  internal _standard          = "ERC20";
    uint8   internal _decimals          = 18;
    uint    internal _totalSupply       = 500000 * 1 ether;
    
    mapping(address => uint256)                     internal balances;
    mapping(address => mapping(address => uint256)) internal allowed;

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    constructor () public {
        balances[msg.sender] = totalSupply();
    }

    // Try to prevent sending ETH to SmartContract by mistake.
    function () external payable  {
        revert("This SmartContract is not payable");
    }
    //
    // Getters and Setters
    //
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function standard() public view returns (string memory) {
        return _standard;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    //
    // Contract common functions
    //
    function transfer(address _to, uint256 _value) public returns (bool) {

        require(_to != address(0), "'_to' address has to be set");
        require(_value <= balances[msg.sender], "Insufficient balance");

        balances[msg.sender] = SafeMath.sub(balances[msg.sender], _value);
        balances[_to] = SafeMath.add(balances[_to], _value);

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require (_spender != address(0), "_spender address has to be set");
        require (_value > 0, "'_value' parameter has to be greater than 0");

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

        require(_from != address(0), "'_from' address has to be set");
        require(_to != address(0), "'_to' address has to be set");
        require(_value <= balances[_from], "Insufficient balance");
        require(_value <= allowed[_from][msg.sender], "Insufficient allowance");

        allowed[_from][msg.sender] = SafeMath.sub(allowed[_from][msg.sender], _value);
        balances[_from] = SafeMath.sub(balances[_from], _value);
        balances[_to] = SafeMath.add(balances[_to], _value);

        emit Transfer(_from, _to, _value);

        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }
    
    function burn(uint256 _value) public returns (bool success) {
        require(_value <= balances[msg.sender]);
        balances[msg.sender] = SafeMath.sub(balances[msg.sender], _value);
        _totalSupply = SafeMath.sub(_totalSupply, _value);
        emit Transfer(msg.sender, address(0), _value);
        return true;
    }
}