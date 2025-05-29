



// The macro needs to:
/*
1. Accept a list of token addresses
2. Check user balances
2. Form the batch-tx for the user, which is a set of send operations

*/


IERC20{
    balanceOf(address) external view returns (uint256);
}



ISuperfluidOperations operations = [];
address stakeHelper =  ;//stakeHelper contr

for(uint i =0; i < tokenList.length; i++){

    operations.push(ISuperfluid.Operation(
        BatchOperation.OPERATION_TYPE_ERC2771_FORWARD_CALL, forwarder, abi.encode(stakeHelper, msgSender, bytes("0x"))
    ));
}