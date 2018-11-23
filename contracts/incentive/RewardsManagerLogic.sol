pragma solidity ^0.5.0;

import "../openzeppelin-solidity/SafeMath.sol";
import "./TRU.sol";

contract RewardsManagerLogic {
    using SafeMath for uint;

    event RewardDeposit(bytes32 indexed task, address who, uint amount, uint tax);
    event RewardClaimed(bytes32 indexed task, address who, uint amount, uint tax);
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function getTaskReward(bytes32 taskID) public view returns (uint) {
        return rewards[taskID];
    }

    function depositReward(bytes32 taskID, uint reward, uint tax) internal returns (bool) {
        // require(token.allowance(msg.sender, address(this)) >= reward + tax);
        // token.transferFrom(msg.sender, address(this), reward + tax);

        rewards[taskID] = rewards[taskID].add(reward);
        taxes[taskID] = rewards[taskID].add(tax);
        emit RewardDeposit(taskID, msg.sender, reward, tax);
        return true; 
    }

    function payReward(bytes32 taskID, address to) internal returns (bool) {
        require(rewards[taskID] > 0);
        uint payout = rewards[taskID];
        rewards[taskID] = 0;

        uint tax = taxes[taskID];
        taxes[taskID] = 0;
        // No minting, so just keep the tokens here
        // token.burn(tax); 

        token.transfer(to, payout);
        emit RewardClaimed(taskID, to, payout, tax);
        return true;
    }

    function getTax(bytes32 taskID) public view returns (uint) {
        return taxes[taskID];
    }

}
