pragma solidity ^0.5.0;

import "../openzeppelin-solidity/Ownable.sol";

contract ExchangeRateOracle is Ownable {
    uint public constant priceOfCyclemUSD = 1;
    uint public TRUperUSD;
    uint public priceOfCycleTRU;

    constructor() public Ownable() {}

    event ExchangeRateUpdate(uint indexed TRUperUSD, address owner);

    function updateExchangeRate (uint _TRUperUSD) public onlyOwner {
        require(_TRUperUSD!= 0);
        TRUperUSD = _TRUperUSD;
        priceOfCycleTRU = TRUperUSD * priceOfCyclemUSD / 1000;
        emit ExchangeRateUpdate(TRUperUSD, owner);
    }

    function getMinDeposit (uint taskDifficulty) public view returns (uint) {
        return taskDifficulty * priceOfCycleTRU + 1;
    }
}
