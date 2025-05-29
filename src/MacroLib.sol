// forgefmt: disable-start
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {
    BatchOperation,
    IConstantFlowAgreementV1,
    IGeneralDistributionAgreementV1,
    ISuperToken,
    ISuperfluid,
    ISuperfluidPool,
    PoolConfig,
    PoolERC20Metadata
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";

/// @title SuperfluidOperationEncoder
/// @notice Library to help encode ISuperfluid.Operation structs for Superfluid batchCall
library SuperfluidOperationEncoder {

    /// @notice Encodes an ERC20 approve operation (calls ERC20.approve)
    function opERC20Approve(address token, address spender, uint256 amount)
        internal
        pure
        returns (ISuperfluid.Operation memory)
    {
        return ISuperfluid.Operation(BatchOperation.OPERATION_TYPE_ERC20_APPROVE, token, abi.encode(spender, amount));
    }

    /// @notice Encodes an ERC20 transferFrom operation (calls ERC20.transferFrom)
    function opERC20TransferFrom(address token, address sender, address receiver, uint256 amount)
        internal
        pure
        returns (ISuperfluid.Operation memory)
    {
        return ISuperfluid.Operation(
            BatchOperation.OPERATION_TYPE_ERC20_TRANSFER_FROM, token, abi.encode(sender, receiver, amount)
        );
    }

    /// @notice Encodes an ERC777 send operation (calls ERC777.send)
    function opERC777Send(address token, address recipient, uint256 amount, bytes memory userData)
        internal
        pure
        returns (ISuperfluid.Operation memory)
    {
        return ISuperfluid.Operation(
            BatchOperation.OPERATION_TYPE_ERC777_SEND, token, abi.encode(recipient, amount, userData)
        );
    }

    /// @notice Encodes an ERC20 increaseAllowance operation (calls ERC20.increaseAllowance)
    function opERC20IncreaseAllowance(address token, address spender, uint256 addedValue)
        internal
        pure
        returns (ISuperfluid.Operation memory)
    {
        return ISuperfluid.Operation(
            BatchOperation.OPERATION_TYPE_ERC20_INCREASE_ALLOWANCE, token, abi.encode(spender, addedValue)
        );
    }

    /// @notice Encodes an ERC20 decreaseAllowance operation (calls ERC20.decreaseAllowance)
    function opERC20DecreaseAllowance(address token, address spender, uint256 subtractedValue)
        internal
        pure
        returns (ISuperfluid.Operation memory)
    {
        return ISuperfluid.Operation(
            BatchOperation.OPERATION_TYPE_ERC20_DECREASE_ALLOWANCE, token, abi.encode(spender, subtractedValue)
        );
    }

    /// @notice Encodes a SuperToken upgrade operation (calls SuperToken.upgrade)
    function opSuperTokenUpgrade(address token, uint256 amount) internal pure returns (ISuperfluid.Operation memory) {
        return ISuperfluid.Operation(BatchOperation.OPERATION_TYPE_SUPERTOKEN_UPGRADE, token, abi.encode(amount));
    }

    /// @notice Encodes a SuperToken downgrade operation (calls SuperToken.downgrade)
    function opSuperTokenDowngrade(address token, uint256 amount)
        internal
        pure
        returns (ISuperfluid.Operation memory)
    {
        return ISuperfluid.Operation(BatchOperation.OPERATION_TYPE_SUPERTOKEN_DOWNGRADE, token, abi.encode(amount));
    }

    /// @notice Encodes a SuperToken upgradeTo operation (calls SuperToken.upgradeTo)
    function opSuperTokenUpgradeTo(address token, address to, uint256 amount)
        internal
        pure
        returns (ISuperfluid.Operation memory)
    {
        return ISuperfluid.Operation(BatchOperation.OPERATION_TYPE_SUPERTOKEN_UPGRADE_TO, token, abi.encode(to, amount));
    }

    /// @notice Encodes a SuperToken downgradeTo operation (calls SuperToken.downgradeTo)
    function opSuperTokenDowngradeTo(address token, address to, uint256 amount)
        internal
        pure
        returns (ISuperfluid.Operation memory)
    {
        return
            ISuperfluid.Operation(BatchOperation.OPERATION_TYPE_SUPERTOKEN_DOWNGRADE_TO, token, abi.encode(to, amount));
    }

    /// @notice Encodes a Superfluid callAgreement operation (calls Superfluid.callAgreement)
    function opSuperfluidCallAgreement(address agreement, bytes memory callData, bytes memory userData)
        internal
        pure
        returns (ISuperfluid.Operation memory)
    {
        return ISuperfluid.Operation(
            BatchOperation.OPERATION_TYPE_SUPERFLUID_CALL_AGREEMENT, agreement, abi.encode(callData, userData)
        );
    }

    /// @notice Encodes a CFAv1 createFlow operation (calls IConstantFlowAgreementV1.createFlow)
    function opCFAv1CreateFlow(address cfa, ISuperToken token, address receiver, int96 flowrate, bytes memory userData)
        internal
        pure
        returns (ISuperfluid.Operation memory)
    {
        return opCFAv1CreateFlowWithCtx(cfa, token, receiver, flowrate, new bytes(0), userData);
    }

    /// @notice Encodes a CFAv1 createFlow operation with a custom ctx (calls IConstantFlowAgreementV1.createFlow)
    function opCFAv1CreateFlowWithCtx(
        address cfa,
        ISuperToken token,
        address receiver,
        int96 flowrate,
        bytes memory ctx,
        bytes memory userData
    ) internal pure returns (ISuperfluid.Operation memory) {
        IConstantFlowAgreementV1 cfaContract = IConstantFlowAgreementV1(cfa);
        bytes memory callData = abi.encodeCall(cfaContract.createFlow, (token, receiver, flowrate, ctx));
        return opSuperfluidCallAgreement(cfa, callData, userData);
    }

    /// @notice Encodes a CFAv1 createFlowByOperator operation (calls IConstantFlowAgreementV1.createFlowByOperator)
    function opCFAv1CreateFlowByOperator(
        address cfa,
        ISuperToken token,
        address sender,
        address receiver,
        int96 flowrate,
        bytes memory userData
    ) internal pure returns (ISuperfluid.Operation memory) {
        return opCFAv1CreateFlowByOperatorWithCtx(cfa, token, sender, receiver, flowrate, new bytes(0), userData);
    }

    /// @notice Encodes a CFAv1 createFlowByOperator operation with a custom ctx (calls IConstantFlowAgreementV1.createFlowByOperator)
    function opCFAv1CreateFlowByOperatorWithCtx(
        address cfa,
        ISuperToken token,
        address sender,
        address receiver,
        int96 flowrate,
        bytes memory ctx,
        bytes memory userData
    ) internal pure returns (ISuperfluid.Operation memory) {
        IConstantFlowAgreementV1 cfaContract = IConstantFlowAgreementV1(cfa);
        bytes memory callData =
            abi.encodeCall(cfaContract.createFlowByOperator, (token, sender, receiver, flowrate, ctx));
        return opSuperfluidCallAgreement(cfa, callData, userData);
    }

    /// @notice Encodes a CFAv1 updateFlow operation (calls IConstantFlowAgreementV1.updateFlow)
    function opCFAv1UpdateFlow(address cfa, ISuperToken token, address receiver, int96 flowrate, bytes memory userData)
        internal
        pure
        returns (ISuperfluid.Operation memory)
    {
        return opCFAv1UpdateFlowWithCtx(cfa, token, receiver, flowrate, new bytes(0), userData);
    }

    /// @notice Encodes a CFAv1 updateFlow operation with a custom ctx (calls IConstantFlowAgreementV1.updateFlow)
    function opCFAv1UpdateFlowWithCtx(
        address cfa,
        ISuperToken token,
        address receiver,
        int96 flowrate,
        bytes memory ctx,
        bytes memory userData
    ) internal pure returns (ISuperfluid.Operation memory) {
        IConstantFlowAgreementV1 cfaContract = IConstantFlowAgreementV1(cfa);
        bytes memory callData = abi.encodeCall(cfaContract.updateFlow, (token, receiver, flowrate, ctx));
        return opSuperfluidCallAgreement(cfa, callData, userData);
    }

    /// @notice Encodes a CFAv1 updateFlowByOperator operation (calls IConstantFlowAgreementV1.updateFlowByOperator)
    function opCFAv1UpdateFlowByOperator(
        address cfa,
        ISuperToken token,
        address sender,
        address receiver,
        int96 flowrate,
        bytes memory userData
    ) internal pure returns (ISuperfluid.Operation memory) {
        return opCFAv1UpdateFlowByOperatorWithCtx(cfa, token, sender, receiver, flowrate, new bytes(0), userData);
    }

    /// @notice Encodes a CFAv1 updateFlowByOperator operation with a custom ctx (calls IConstantFlowAgreementV1.updateFlowByOperator)
    function opCFAv1UpdateFlowByOperatorWithCtx(
        address cfa,
        ISuperToken token,
        address sender,
        address receiver,
        int96 flowrate,
        bytes memory ctx,
        bytes memory userData
    ) internal pure returns (ISuperfluid.Operation memory) {
        IConstantFlowAgreementV1 cfaContract = IConstantFlowAgreementV1(cfa);
        bytes memory callData =
            abi.encodeCall(cfaContract.updateFlowByOperator, (token, sender, receiver, flowrate, ctx));
        return opSuperfluidCallAgreement(cfa, callData, userData);
    }

    /// @notice Encodes a CFAv1 deleteFlow operation (calls IConstantFlowAgreementV1.deleteFlow)
    function opCFAv1DeleteFlow(address cfa, ISuperToken token, address sender, address receiver, bytes memory userData)
        internal
        pure
        returns (ISuperfluid.Operation memory)
    {
        return opCFAv1DeleteFlowWithCtx(cfa, token, sender, receiver, new bytes(0), userData);
    }

    /// @notice Encodes a CFAv1 deleteFlow operation with a custom ctx (calls IConstantFlowAgreementV1.deleteFlow)
    function opCFAv1DeleteFlowWithCtx(
        address cfa,
        ISuperToken token,
        address sender,
        address receiver,
        bytes memory ctx,
        bytes memory userData
    ) internal pure returns (ISuperfluid.Operation memory) {
        IConstantFlowAgreementV1 cfaContract = IConstantFlowAgreementV1(cfa);
        bytes memory callData = abi.encodeCall(cfaContract.deleteFlow, (token, sender, receiver, ctx));
        return opSuperfluidCallAgreement(cfa, callData, userData);
    }

    /// @notice Encodes a CFAv1 deleteFlowByOperator operation (calls IConstantFlowAgreementV1.deleteFlowByOperator)
    function opCFAv1DeleteFlowByOperator(
        address cfa,
        ISuperToken token,
        address sender,
        address receiver,
        bytes memory userData
    ) internal pure returns (ISuperfluid.Operation memory) {
        return opCFAv1DeleteFlowByOperatorWithCtx(cfa, token, sender, receiver, new bytes(0), userData);
    }

    /// @notice Encodes a CFAv1 deleteFlowByOperator operation with a custom ctx (calls IConstantFlowAgreementV1.deleteFlowByOperator)
    function opCFAv1DeleteFlowByOperatorWithCtx(
        address cfa,
        ISuperToken token,
        address sender,
        address receiver,
        bytes memory ctx,
        bytes memory userData
    ) internal pure returns (ISuperfluid.Operation memory) {
        IConstantFlowAgreementV1 cfaContract = IConstantFlowAgreementV1(cfa);
        bytes memory callData = abi.encodeCall(cfaContract.deleteFlowByOperator, (token, sender, receiver, ctx));
        return opSuperfluidCallAgreement(cfa, callData, userData);
    }

    /// @notice Encodes a CFAv1 updateFlowOperatorPermissions operation (calls IConstantFlowAgreementV1.updateFlowOperatorPermissions)
    function opCFAv1UpdateFlowOperatorPermissions(
        address cfa,
        ISuperToken token,
        address flowOperator,
        uint8 permissions,
        int96 flowRateAllowance,
        bytes memory userData
    ) internal pure returns (ISuperfluid.Operation memory) {
        IConstantFlowAgreementV1 cfaContract = IConstantFlowAgreementV1(cfa);
        bytes memory callData = abi.encodeCall(
            cfaContract.updateFlowOperatorPermissions,
            (token, flowOperator, permissions, flowRateAllowance, new bytes(0))
        );
        return opSuperfluidCallAgreement(cfa, callData, userData);
    }

    /// @notice Encodes a CFAv1 increaseFlowRateAllowance operation (calls IConstantFlowAgreementV1.increaseFlowRateAllowance)
    function opCFAv1IncreaseFlowRateAllowance(
        address cfa,
        ISuperToken token,
        address flowOperator,
        int96 addedFlowRateAllowance,
        bytes memory userData
    ) internal pure returns (ISuperfluid.Operation memory) {
        IConstantFlowAgreementV1 cfaContract = IConstantFlowAgreementV1(cfa);
        bytes memory callData = abi.encodeCall(
            cfaContract.increaseFlowRateAllowance, (token, flowOperator, addedFlowRateAllowance, new bytes(0))
        );
        return opSuperfluidCallAgreement(cfa, callData, userData);
    }

    /// @notice Encodes a CFAv1 decreaseFlowRateAllowance operation (calls IConstantFlowAgreementV1.decreaseFlowRateAllowance)
    function opCFAv1DecreaseFlowRateAllowance(
        address cfa,
        ISuperToken token,
        address flowOperator,
        int96 subtractedFlowRateAllowance,
        bytes memory userData
    ) internal pure returns (ISuperfluid.Operation memory) {
        IConstantFlowAgreementV1 cfaContract = IConstantFlowAgreementV1(cfa);
        bytes memory callData = abi.encodeCall(
            cfaContract.decreaseFlowRateAllowance, (token, flowOperator, subtractedFlowRateAllowance, new bytes(0))
        );
        return opSuperfluidCallAgreement(cfa, callData, userData);
    }

    /// @notice Encodes a CFAv1 increaseFlowRateAllowanceWithPermissions operation (calls IConstantFlowAgreementV1.increaseFlowRateAllowanceWithPermissions)
    function opCFAv1IncreaseFlowRateAllowanceWithPermissions(
        address cfa,
        ISuperToken token,
        address flowOperator,
        uint8 permissionsToAdd,
        int96 addedFlowRateAllowance,
        bytes memory userData
    ) internal pure returns (ISuperfluid.Operation memory) {
        IConstantFlowAgreementV1 cfaContract = IConstantFlowAgreementV1(cfa);
        bytes memory callData = abi.encodeCall(
            cfaContract.increaseFlowRateAllowanceWithPermissions,
            (token, flowOperator, permissionsToAdd, addedFlowRateAllowance, new bytes(0))
        );
        return opSuperfluidCallAgreement(cfa, callData, userData);
    }

    /// @notice Encodes a CFAv1 decreaseFlowRateAllowanceWithPermissions operation (calls IConstantFlowAgreementV1.decreaseFlowRateAllowanceWithPermissions)
    function opCFAv1DecreaseFlowRateAllowanceWithPermissions(
        address cfa,
        ISuperToken token,
        address flowOperator,
        uint8 permissionsToRemove,
        int96 subtractedFlowRateAllowance,
        bytes memory userData
    ) internal pure returns (ISuperfluid.Operation memory) {
        IConstantFlowAgreementV1 cfaContract = IConstantFlowAgreementV1(cfa);
        bytes memory callData = abi.encodeCall(
            cfaContract.decreaseFlowRateAllowanceWithPermissions,
            (token, flowOperator, permissionsToRemove, subtractedFlowRateAllowance, new bytes(0))
        );
        return opSuperfluidCallAgreement(cfa, callData, userData);
    }

    /// @notice Encodes a CFAv1 authorizeFlowOperatorWithFullControl operation (calls IConstantFlowAgreementV1.authorizeFlowOperatorWithFullControl)
    function opCFAv1AuthorizeFlowOperatorWithFullControl(
        address cfa,
        ISuperToken token,
        address flowOperator,
        bytes memory userData
    ) internal pure returns (ISuperfluid.Operation memory) {
        IConstantFlowAgreementV1 cfaContract = IConstantFlowAgreementV1(cfa);
        bytes memory callData =
            abi.encodeCall(cfaContract.authorizeFlowOperatorWithFullControl, (token, flowOperator, new bytes(0)));
        return opSuperfluidCallAgreement(cfa, callData, userData);
    }

    /// @notice Encodes a CFAv1 revokeFlowOperatorWithFullControl operation (calls IConstantFlowAgreementV1.revokeFlowOperatorWithFullControl)
    function opCFAv1RevokeFlowOperatorWithFullControl(
        address cfa,
        ISuperToken token,
        address flowOperator,
        bytes memory userData
    ) internal pure returns (ISuperfluid.Operation memory) {
        IConstantFlowAgreementV1 cfaContract = IConstantFlowAgreementV1(cfa);
        bytes memory callData =
            abi.encodeCall(cfaContract.revokeFlowOperatorWithFullControl, (token, flowOperator, new bytes(0)));
        return opSuperfluidCallAgreement(cfa, callData, userData);
    }

    /// @notice Encodes a GDAv1 updateMemberUnits operation (calls IGeneralDistributionAgreementV1.updateMemberUnits)
    function opGDAv1UpdateMemberUnits(
        address gda,
        ISuperfluidPool pool,
        address memberAddress,
        uint128 newUnits,
        bytes memory userData
    ) internal pure returns (ISuperfluid.Operation memory) {
        IGeneralDistributionAgreementV1 gdaContract = IGeneralDistributionAgreementV1(gda);
        bytes memory callData =
            abi.encodeCall(gdaContract.updateMemberUnits, (pool, memberAddress, newUnits, new bytes(0)));
        return opSuperfluidCallAgreement(gda, callData, userData);
    }

    /// @notice Encodes a GDAv1 updateMemberUnits operation with a custom ctx (calls IGeneralDistributionAgreementV1.updateMemberUnits)
    function opGDAv1UpdateMemberUnitsWithCtx(
        address gda,
        ISuperfluidPool pool,
        address memberAddress,
        uint128 newUnits,
        bytes memory ctx,
        bytes memory userData
    ) internal pure returns (ISuperfluid.Operation memory) {
        IGeneralDistributionAgreementV1 gdaContract = IGeneralDistributionAgreementV1(gda);
        bytes memory callData = abi.encodeCall(gdaContract.updateMemberUnits, (pool, memberAddress, newUnits, ctx));
        return opSuperfluidCallAgreement(gda, callData, userData);
    }

    /// @notice Encodes a GDAv1 claimAll operation (calls IGeneralDistributionAgreementV1.claimAll)
    function opGDAv1ClaimAll(address gda, ISuperfluidPool pool, address memberAddress, bytes memory userData)
        internal
        pure
        returns (ISuperfluid.Operation memory)
    {
        IGeneralDistributionAgreementV1 gdaContract = IGeneralDistributionAgreementV1(gda);
        bytes memory callData = abi.encodeCall(gdaContract.claimAll, (pool, memberAddress, new bytes(0)));
        return opSuperfluidCallAgreement(gda, callData, userData);
    }

    /// @notice Encodes a GDAv1 claimAll operation with a custom ctx (calls IGeneralDistributionAgreementV1.claimAll)
    function opGDAv1ClaimAllWithCtx(
        address gda,
        ISuperfluidPool pool,
        address memberAddress,
        bytes memory ctx,
        bytes memory userData
    ) internal pure returns (ISuperfluid.Operation memory) {
        IGeneralDistributionAgreementV1 gdaContract = IGeneralDistributionAgreementV1(gda);
        bytes memory callData = abi.encodeCall(gdaContract.claimAll, (pool, memberAddress, ctx));
        return opSuperfluidCallAgreement(gda, callData, userData);
    }

    /// @notice Encodes a GDAv1 connectPool operation (calls IGeneralDistributionAgreementV1.connectPool)
    function opGDAv1ConnectPool(address gda, ISuperfluidPool pool, bytes memory userData)
        internal
        pure
        returns (ISuperfluid.Operation memory)
    {
        IGeneralDistributionAgreementV1 gdaContract = IGeneralDistributionAgreementV1(gda);
        bytes memory callData = abi.encodeCall(gdaContract.connectPool, (pool, new bytes(0)));
        return opSuperfluidCallAgreement(gda, callData, userData);
    }

    /// @notice Encodes a GDAv1 connectPool operation with a custom ctx (calls IGeneralDistributionAgreementV1.connectPool)
    function opGDAv1ConnectPoolWithCtx(
        address gda,
        ISuperfluidPool pool,
        bytes memory ctx,
        bytes memory userData
    ) internal pure returns (ISuperfluid.Operation memory) {
        IGeneralDistributionAgreementV1 gdaContract = IGeneralDistributionAgreementV1(gda);
        bytes memory callData = abi.encodeCall(gdaContract.connectPool, (pool, ctx));
        return opSuperfluidCallAgreement(gda, callData, userData);
    }

    /// @notice Encodes a GDAv1 disconnectPool operation (calls IGeneralDistributionAgreementV1.disconnectPool)
    function opGDAv1DisconnectPool(address gda, ISuperfluidPool pool, bytes memory userData)
        internal
        pure
        returns (ISuperfluid.Operation memory)
    {
        IGeneralDistributionAgreementV1 gdaContract = IGeneralDistributionAgreementV1(gda);
        bytes memory callData = abi.encodeCall(gdaContract.disconnectPool, (pool, new bytes(0)));
        return opSuperfluidCallAgreement(gda, callData, userData);
    }

    /// @notice Encodes a GDAv1 disconnectPool operation with a custom ctx (calls IGeneralDistributionAgreementV1.disconnectPool)
    function opGDAv1DisconnectPoolWithCtx(
        address gda,
        ISuperfluidPool pool,
        bytes memory ctx,
        bytes memory userData
    ) internal pure returns (ISuperfluid.Operation memory) {
        IGeneralDistributionAgreementV1 gdaContract = IGeneralDistributionAgreementV1(gda);
        bytes memory callData = abi.encodeCall(gdaContract.disconnectPool, (pool, ctx));
        return opSuperfluidCallAgreement(gda, callData, userData);
    }

    /// @notice Encodes a GDAv1 distributeFlow operation (calls IGeneralDistributionAgreementV1.distributeFlow)
    function opGDAv1DistributeFlow(
        address gda,
        ISuperToken token,
        address from,
        ISuperfluidPool pool,
        int96 requestedFlowRate,
        bytes memory userData
    ) internal pure returns (ISuperfluid.Operation memory) {
        IGeneralDistributionAgreementV1 gdaContract = IGeneralDistributionAgreementV1(gda);
        bytes memory callData =
            abi.encodeCall(gdaContract.distributeFlow, (token, from, pool, requestedFlowRate, new bytes(0)));
        return opSuperfluidCallAgreement(gda, callData, userData);
    }

    /// @notice Encodes a GDAv1 distributeFlow operation with a custom ctx (calls IGeneralDistributionAgreementV1.distributeFlow)
    function opGDAv1DistributeFlowWithCtx(
        address gda,
        ISuperToken token,
        address from,
        ISuperfluidPool pool,
        int96 requestedFlowRate,
        bytes memory ctx,
        bytes memory userData
    ) internal pure returns (ISuperfluid.Operation memory) {
        IGeneralDistributionAgreementV1 gdaContract = IGeneralDistributionAgreementV1(gda);
        bytes memory callData = abi.encodeCall(gdaContract.distributeFlow, (token, from, pool, requestedFlowRate, ctx));
        return opSuperfluidCallAgreement(gda, callData, userData);
    }

    /// @notice Encodes a GDAv1 createPool operation (calls IGeneralDistributionAgreementV1.createPool)
    function opGDAv1CreatePool(
        address gda,
        ISuperToken token,
        address admin,
        PoolConfig memory poolConfig,
        bytes memory userData
    ) internal pure returns (ISuperfluid.Operation memory) {
        IGeneralDistributionAgreementV1 gdaContract = IGeneralDistributionAgreementV1(gda);
        bytes memory callData = abi.encodeCall(gdaContract.createPool, (token, admin, poolConfig));
        return opSuperfluidCallAgreement(gda, callData, userData);
    }

    /// @notice Encodes a GDAv1 createPoolWithCustomERC20Metadata operation (calls IGeneralDistributionAgreementV1.createPoolWithCustomERC20Metadata)
    function opGDAv1CreatePoolWithCustomERC20Metadata(
        address gda,
        ISuperToken token,
        address admin,
        PoolConfig memory poolConfig,
        PoolERC20Metadata memory poolERC20Metadata,
        bytes memory userData
    ) internal pure returns (ISuperfluid.Operation memory) {
        IGeneralDistributionAgreementV1 gdaContract = IGeneralDistributionAgreementV1(gda);
        bytes memory callData =
            abi.encodeCall(gdaContract.createPoolWithCustomERC20Metadata, (token, admin, poolConfig, poolERC20Metadata));
        return opSuperfluidCallAgreement(gda, callData, userData);
    }

    /// @notice Encodes a GDAv1 distribute operation (calls IGeneralDistributionAgreementV1.distribute)
    function opGDAv1Distribute(
        address gda,
        ISuperToken token,
        address from,
        ISuperfluidPool pool,
        uint256 requestedAmount,
        bytes memory userData
    ) internal pure returns (ISuperfluid.Operation memory) {
        IGeneralDistributionAgreementV1 gdaContract = IGeneralDistributionAgreementV1(gda);
        bytes memory callData =
            abi.encodeCall(gdaContract.distribute, (token, from, pool, requestedAmount, new bytes(0)));
        return opSuperfluidCallAgreement(gda, callData, userData);
    }

    /// @notice Encodes a GDAv1 distribute operation with a custom ctx (calls IGeneralDistributionAgreementV1.distribute)
    function opGDAv1DistributeWithCtx(
        address gda,
        ISuperToken token,
        address from,
        ISuperfluidPool pool,
        uint256 requestedAmount,
        bytes memory ctx,
        bytes memory userData
    ) internal pure returns (ISuperfluid.Operation memory) {
        IGeneralDistributionAgreementV1 gdaContract = IGeneralDistributionAgreementV1(gda);
        bytes memory callData = abi.encodeCall(gdaContract.distribute, (token, from, pool, requestedAmount, ctx));
        return opSuperfluidCallAgreement(gda, callData, userData);
    }

    /// @notice Encodes a Superfluid callAppAction operation (calls Superfluid.callAppAction)
    function opSuperfluidCallAppAction(address app, bytes memory callData)
        internal
        pure
        returns (ISuperfluid.Operation memory)
    {
        return ISuperfluid.Operation(BatchOperation.OPERATION_TYPE_SUPERFLUID_CALL_APP_ACTION, app, callData);
    }

    /// @notice Encodes a SimpleForwarder forwardCall operation (calls SimpleForwarder.forwardCall)
    function opSimpleForwardCall(address forwarder, address target, bytes memory data)
        internal
        pure
        returns (ISuperfluid.Operation memory)
    {
        return ISuperfluid.Operation(
            BatchOperation.OPERATION_TYPE_SIMPLE_FORWARD_CALL, forwarder, abi.encode(target, data)
        );
    }

    /// @notice Encodes an ERC2771Forwarder forward2771Call operation (calls ERC2771Forwarder.forward2771Call)
    function opERC2771ForwardCall(address forwarder, address target, address msgSender, bytes memory data)
        internal
        pure
        returns (ISuperfluid.Operation memory)
    {
        return ISuperfluid.Operation(
            BatchOperation.OPERATION_TYPE_ERC2771_FORWARD_CALL, forwarder, abi.encode(target, msgSender, data)
        );
    }

}