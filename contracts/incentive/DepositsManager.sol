pragma solidity ^0.5.0;

import "../openzeppelin-solidity/SafeMath.sol";
import "./TRU.sol";

contract DepositsManager {
    using SafeMath for uint;

    mapping(address => uint) public deposits;
    address public owner;
    TRU public token;
    address public truebit;

    event DepositMade(address who, uint amount);
    event DepositWithdrawn(address who, uint amount);

    // @dev – the constructor
    constructor(address payable _tru, address _truebit) public {
        owner = msg.sender;
        token = TRU(_tru);
	truebit = _truebit;
    }
    
    // @dev - fallback does nothing since we only accept TRU tokens
    function () external payable {
        revert();
    }

    // @dev – returns an account's deposit
    // @param who – the account's address.
    // @return – the account's deposit.
    function getDeposit(address who) view public returns (uint) {
        return deposits[who];
    }

    // @dev - allows a user to deposit TRU tokens
    // @return - the uer's update deposit amount
    function makeDeposit(uint _deposit) public payable returns (uint) {
	require(_deposit > 0);
        require(token.allowance(msg.sender, address(this)) >= _deposit);
        token.transferFrom(msg.sender, address(this), _deposit);

        deposits[msg.sender] = deposits[msg.sender].add(_deposit);
        emit DepositMade(msg.sender, _deposit);
        return deposits[msg.sender];
    }

    function bondDeposit(address account, uint amount) public returns (uint) {
      	require(msg.sender == truebit);
        require(deposits[account] >= amount);

	deposits[account] = deposits[account].sub(amount);
	deposits[address(this)] = deposits[address(this)].add(amount);
    }

    function unbondDeposit(address account, uint amount) public returns (uint) {
        require(msg.sender == truebit);
	require(deposits[address(this)] >= amount);

	deposits[address(this)] = deposits[address(this)].sub(amount);
	deposits[account] = deposits[account].add(amount);
    }

    function transferBondedDeposit(address to, uint amount) public returns (uint) {
	require(msg.sender == truebit);
	require(deposits[address(this)] >= amount);
      
	deposits[address(this)] = deposits[address(this)].sub(amount);
	deposits[to] = deposits[to].add(amount);
    }

    // @dev - allows a user to withdraw TRU from their deposit
    // @param amount - how much TRU to withdraw
    // @return - the user's updated deposit
    function withdrawDeposit(uint amount) public returns (uint) {
        require(deposits[msg.sender] >= amount);
        
        deposits[msg.sender] = deposits[msg.sender].sub(amount);
        token.transfer(msg.sender, amount);

        emit DepositWithdrawn(msg.sender, amount);
        return deposits[msg.sender];
    }

    function withdrawRewardAndTax(address account, uint reward, uint tax) public returns (uint) {
	require(msg.sender == truebit);
	uint amount = reward + tax;
	require(deposits[account] >= amount);
	deposits[account] = deposits[account].sub(amount);
	return amount;
    }

}
