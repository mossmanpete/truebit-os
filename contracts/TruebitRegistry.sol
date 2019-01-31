pragma solidity ^0.5.0;

contract TruebitRegistry {

    constructor() public payable {
	 owner = msg.sender;
    }

    address owner;
  
    struct Contracts {
	address TRU;
	address exchangeRateOracle;
	address filesystem;
	address jackpotManager;
	address payable depositsManager;
	address rewardsManager;
	address incentiveLayer;
	address disputeResolutionLayer;
    }

    Contracts contracts;

    function setContracts(
			  address _tru,
			  address _exchangeRateOracle,
			  address _filesystem,
			  address _jackpotManager,
			  address payable _depositsManager,
			  address _rewardsManager,
			  address _incentiveLayer,
			  address _disputeResolutionLayer
			  ) public
    {
	require(msg.sender == owner);
	contracts = Contracts(
			      _tru,
			      _exchangeRateOracle,
			      _filesystem,
			      _jackpotManager,
			      _depositsManager,
			      _rewardsManager,
			      _incentiveLayer,
			      _disputeResolutionLayer
			      );
    }

    function getContracts() public view returns (
						 address,
						 address,
						 address,
						 address,
						 address payable,
						 address,
						 address,
						 address
						 )
    {
	return (
		contracts.TRU,
		contracts.exchangeRateOracle,
		contracts.filesystem,
		contracts.jackpotManager,
		contracts.depositsManager,
		contracts.rewardsManager,
		contracts.incentiveLayer,
		contracts.disputeResolutionLayer
		);
    }

    function getIncentiveLayer() public view returns (address) {
	return contracts.incentiveLayer;
    }

    function getTRU() public view returns (address) {
	return contracts.TRU;
    }

    function getDepositsManager() public view returns (address) {
	return contracts.depositsManager;
    }

    function getDisputeResolutionLayer() public view returns (address) {
	return contracts.disputeResolutionLayer;
    }
  
}
