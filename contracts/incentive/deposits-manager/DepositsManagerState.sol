pragma solidity ^0.5.0;

import "../../openzeppelin-solidity/SafeMath.sol";
import "../TRU.sol";

contract DepositsManagerState {
    using SafeMath for uint;

    mapping(address => uint) public deposits;
    address public owner;
    TRU public token;    
}
