pragma solidity ^0.5.0;

interface ICallback {
    function solved(bytes32 taskID, bytes32[] calldata files) external;
    function cancelled(bytes32 taskID) external;    
}
