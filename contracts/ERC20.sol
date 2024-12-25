//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./IERC20.sol";
import "hardhat/console.sol";

abstract contract ERC20 is IERC20 {
  // Variables
  string private _name;
  string private _symbol;
  uint8 private _decimals;
  uint256 private _totalSupply;
  address private _founder;
  mapping(address => uint256) private _balances;
  mapping(address account => mapping(address spender => uint256)) private _allowances;

  // Modifiers
  modifier restrictFromZeroAddress() {
    require(msg.sender != address(0), "ERC20InvalidSender");
    _;
  }

  modifier restrictToZeroAddress(address _to) {
    require(_to != address(0), "ERC20InvalidReceiver");
    _;
  }

  // Custom errors
  error InsufficientBalance(address _sender, uint256 _sender_balance, uint256 _requested_balance);

  constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 totalSupply_, address founder_)
  {
    _name = name_;
    _symbol = symbol_;
    _decimals = decimals_;
    _totalSupply = totalSupply_;
    _founder = founder_;
    _balances[_founder] = totalSupply_;
  }

  // View functions
  function name()
    public
    view
    virtual
    returns(string memory)
  {
    return _name;
  }

  function symbol()
    public
    view
    virtual
    returns(string memory)
  {
    return _symbol;
  }

  function decimals()
    public
    view
    virtual
    returns(uint8)
  {
    return _decimals;
  }

  function totalSupply()
    public
    view
    virtual
    returns(uint256)
  {
    return _totalSupply;
  }

  function balanceOf(address _owner)
    public
    view
    virtual
    returns(uint256)
  {
    return _balances[_owner];
  }

  function burntTokens()
    public
    view
    virtual
    returns(uint256)
  {
    return _balances[address(0)];
  }

  // Main functions
  function transfer(address _to, uint256 _value)
    public
    virtual
    restrictFromZeroAddress()
    restrictToZeroAddress(_to)
    returns(bool)
  {
    if (_balances[msg.sender] <= _value) {
      revert InsufficientBalance(msg.sender, _balances[msg.sender], _value);
    } else {
      _balances[msg.sender] -= _value;
      _balances[_to] += _value;

      emit Transfer(msg.sender, _to, _value);

      return true;
    }
  }

  function transferFrom(address _from, address _to, uint256 _value)
    public
    virtual
    restrictFromZeroAddress()
    restrictToZeroAddress(_to)
    returns(bool)
  {
    // Checking allowed balance
    uint256 currentAllowance = allowance(_from, msg.sender);
    require(currentAllowance >= _value, "Requested amount exceeds the allowed amount.");
    unchecked{
      _approve(_from, msg.sender, currentAllowance - _value);
    }

    require(_balances[_from] >= _value, "InsufficientBalance");

    // Updating the balances
    _balances[_from] -= _value;
    _balances[_to] += _value;

    emit Transfer(_from, _to, _value);

    return true;
  }

  function approve(address _spender, uint256 _value)
    public
    virtual
    returns(bool)
  {
    _approve(msg.sender, _spender, _value);
    return true;
  }

  function _approve(address _owner, address _spender, uint256 _value)
    internal
    restrictFromZeroAddress()
    restrictToZeroAddress(_spender)
  {
    _allowances[_owner][_spender] = _value;
    emit Approval(_owner, _spender, _value);
  }

 function allowance(address _owner, address _spender)
    public
    view
    virtual
    returns(uint256)
  {
    return _allowances[_owner][_spender];
  }

  function mint(address _to, uint256 _value)
    public
    virtual
    restrictFromZeroAddress()
    restrictToZeroAddress(_to)
    returns(bool)
  {
    require(msg.sender == _founder, "Only the founding body can mint tokens.");
    transfer(_to, _value);
    return true;
  }

  function burn(uint256 _value)
    public
    virtual
    restrictFromZeroAddress()
    returns(bool)
  {
    require(msg.sender == _founder, "Only the founding body can burn tokens.");

    if (_balances[msg.sender] <= _value) {
      revert InsufficientBalance(msg.sender, _balances[msg.sender], _value);
    } else {
      _balances[msg.sender] -= _value;
      _balances[address(0)] += _value;

      _totalSupply -= _value;

      emit Transfer(msg.sender, address(0), _value);

    return true;
    }
  }

  function transferAllAllowance(address _from, address _to)
    public
    virtual
    restrictFromZeroAddress()
    restrictToZeroAddress(_to)
    returns(bool)
  {
    uint256 totalAllowance = allowance(_from, msg.sender);
    transferFrom(_from, _to, totalAllowance);
    return true;
  }

}
