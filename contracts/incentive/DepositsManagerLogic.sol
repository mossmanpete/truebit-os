pragma solidity ^0.5.0;

import "../openzeppelin-solidity/SafeMath.sol";
import "./TRU.sol";

contract DepositsManager {
    using SafeMath for uint;

    event DepositMade(address who, uint amount);
    event DepositWithdrawn(address who, uint amount);

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
    
}
