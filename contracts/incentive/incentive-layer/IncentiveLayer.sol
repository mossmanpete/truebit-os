pragma solidity ^0.5.0;

import "../../dispute/Filesystem.sol";
import "../ExchangeRateOracle.sol";
import "../../openzeppelin-solidity/Registry.sol";
import "./IncentiveLayerState.sol";

contract IncentiveLayer is Registry, IncentiveLayerState {

    constructor (address payable _TRU, address _exchangeRateOracle, address _disputeResolutionLayer, address fs_addr) public {
        disputeResolutionLayer = _disputeResolutionLayer;
        oracle = ExchangeRateOracle(_exchangeRateOracle);
        fs = Filesystem(fs_addr);
        tru = TRU(_TRU);
	owner = msg.sender;
    }

}
