pragma solidity ^0.5.0;

import "../../openzeppelin-solidity/SafeMath.sol";
import "../TRU.sol";

contract JackpotManagerState {
    using SafeMath for uint;

    struct Jackpot {
        uint finalAmount;
        uint amount;
        address[] challengers;
        uint redeemedCount;
    }

    mapping(uint => Jackpot) jackpots;//keeps track of versions of jackpots

    uint internal currentJackpotID;
    TRU public token;
    
}
