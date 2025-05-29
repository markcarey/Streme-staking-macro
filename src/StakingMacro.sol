



// The macro needs to:
/*
1. Accept a list of token addresses
2. Check user balances
2. Form the batch-tx for the user, which is a set of send operations

*/


interface IERC20{
    function balanceOf(address) external view returns (uint256);
}

contract StakingMacro{


    function buildBatchOperations(ISuperfluid host, bytes memory params, address msgSender)
    external
    view
    override
    returns (ISuperfluid.Operation[] memory operations)
{
    (address[] memory tokens, address stakeHelper) =
        _decodeBatchParams(params);

    ISuperfluidOperations operations = [];

    for(uint i =0; i < tokens.length; i++){
        operations.push(ISuperfluid.Operation(
            BatchOperation.OPERATION_TYPE_ERC2771_FORWARD_CALL, forwarder, abi.encode(stakeHelper, msgSender, bytes("0x"))
        ));
    }
    return operations;
}
}   