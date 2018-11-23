pragma solidity ^0.5.0;

contract IncentiveLayerState {
    uint private numTasks = 0;
    uint private forcedErrorThreshold = 500000; // should mean 100000/1000000 probability
    uint private taxMultiplier = 5;

    mapping(bytes32 => Task) private tasks;
    mapping(bytes32 => Solution) private solutions;
    mapping(bytes32 => VMParameters) private vmParams;
    mapping (bytes32 => uint) challenges;    

    ExchangeRateOracle oracle;
    address disputeResolutionLayer; //using address type because in some cases it is IGameMaker, and others IDisputeResolutionLayer
    Filesystem fs;
    TRU tru;

    uint constant TIMEOUT = 100;

    enum CodeType {
        WAST,
        WASM,
        INTERNAL
    }

    enum StorageType {
        IPFS,
        BLOCKCHAIN
    }

    struct VMParameters {
        uint8 stackSize;
        uint8 memorySize;
        uint8 callSize;
        uint8 globalsSize;
        uint8 tableSize;
        uint32 gasLimit;
    }

    enum State { TaskInitialized, SolverSelected, SolutionCommitted, ChallengesAccepted, IntentsRevealed, SolutionRevealed, TaskFinalized, TaskTimeout }
    enum Status { Uninitialized, Challenged, Unresolved, SolverWon, ChallengerWon }//For dispute resolution
    
    struct RequiredFile {
        bytes32 nameHash;
        StorageType fileStorage;
        bytes32 fileId;
    }
    
    struct Task {
        address owner;
        address selectedSolver;
        uint minDeposit;
        uint reward;
        uint tax;
        bytes32 initTaskHash;
        mapping(address => bytes32) challenges;
        State state;
        bytes32 blockhash;
        bytes32 randomBitsHash;
        mapping(address => uint) bondedDeposits;
        uint randomBits;
        uint finalityCode; // 0 => not finalized, 1 => finalized, 2 => forced error occurred
        uint jackpotID;
        uint cost;
        CodeType codeType;
        StorageType storageType;
        string storageAddress;
        
        bool requiredCommitted;
        RequiredFile[] uploads;
        
        uint lastBlock; // Used to check timeout
        uint challengePeriod;
    }

    struct Solution {
        bytes32 solutionHash0;
        bytes32 solutionHash1;
        bool solution0Correct;
        address[] solution0Challengers;
        address[] solution1Challengers;
        address[] allChallengers;
        address currentChallenger;
        bool solverConvicted;
        bytes32 currentGame;
        
        bytes32 dataHash;
        bytes32 sizeHash;
        bytes32 nameHash;
    }

    mapping(bytes32 => Task) private tasks;
    mapping(bytes32 => Solution) private solutions;
    mapping(bytes32 => VMParameters) private vmParams;
    mapping (bytes32 => uint) challenges;    

    ExchangeRateOracle oracle;
    address disputeResolutionLayer; //using address type because in some cases it is IGameMaker, and others IDisputeResolutionLayer
    Filesystem fs;
    TRU tru;
    
}
