// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ISuperfluid, BatchOperation, IConstantFlowAgreementV1, ISuperToken }
    from "@superfluid-finance/contracts/interfaces/superfluid/ISuperfluid.sol";
import { IUserDefinedMacro } from "@superfluid-finance/contracts/interfaces/utils/IUserDefinedMacro.sol";
import { IGeneralDistributionAgreementV1 } from "@superfluid-finance/contracts/interfaces/agreements/gdav1/IGeneralDistributionAgreementV1.sol";
import { ISuperfluidPool } from "@superfluid-finance/contracts/interfaces/agreements/gdav1/ISuperfluidPool.sol";
import { IStakingHelper } from "./interfaces/IStakingHelper.sol";
import { StakingHelper } from "./StakingHelper.sol";

// The macro needs to:
/*
1. Accept a list of token addresses
2. Check user balances
3. Form the batch-tx for the user, which is a set of send operations
4. Check if users are connected to the staking contract's Distribution Pool, and if not, connect them

*/

interface IGetPool{
    function pool(address token) external view returns (address);
}

contract StakingMacro is IUserDefinedMacro{


    StakingHelper stakeHelper = StakingHelper(0x39464d829f8432E8eCd7FEDab6abe4E264D02E0C);

    // This function is called by the macro forwarder to build the batch operations
    function buildBatchOperations(ISuperfluid /*host*/, bytes memory params, address msgSender)
    public
    view
    override
    returns (ISuperfluid.Operation[] memory operations)
    {
        (address[] memory tokens) = abi.decode(params, (address[]));

        // First, count how many operations we'll actually need
        uint256 operationCount = 0;
        for(uint i = 0; i < tokens.length; i++){
            uint256 balance = ISuperToken(tokens[i]).balanceOf(msgSender);
            if(balance > 0){
                operationCount++;
            }
        }
        
        // Initialize operations array with the correct size
        operations = new ISuperfluid.Operation[](operationCount);
        
        // Now populate the operations array
        uint256 operationIndex = 0;
        for(uint i = 0; i < tokens.length; i++){
            uint256 balance = ISuperToken(tokens[i]).balanceOf(msgSender);
            if(balance > 0){
                operations[operationIndex] = ISuperfluid.Operation(
                    BatchOperation.OPERATION_TYPE_ERC777_SEND, 
                    tokens[i], 
                    abi.encode(address(stakeHelper), balance, "")
                );
                operationIndex++;
            }
        }
        
        return operations;
    }

    // returns the abi encoded params for the macro, to be used with buildBatchOperations
    function getParams(address[] memory tokens) external pure returns (bytes memory) {
        return abi.encode(tokens);
    }

    function postCheck(ISuperfluid host, bytes memory params, address msgSender) external view {
    }
}   