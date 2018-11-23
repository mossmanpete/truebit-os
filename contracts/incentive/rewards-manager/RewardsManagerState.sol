pragma solidity ^0.5.0;

import "../../openzeppelin-solidity/SafeMath.sol";
import "../TRU.sol";

contract RewardsManagerState {
    using SafeMath for uint;

    mapping(bytes32 => uint) public rewards;
    mapping(bytes32 => uint) public taxes;
    address public owner;
    TRU public token;
    
}
