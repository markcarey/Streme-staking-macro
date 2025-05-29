// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/StakingHelperV2.sol";
import "../src/StakingMacroV2.sol";
import {ISuperToken} from "@superfluid-finance/contracts/interfaces/superfluid/ISuperfluid.sol";
import "forge-std/console.sol";
import "../src/interfaces/IStakingHelper.sol";

/**
 * @title DeployStakingHelperV2
 * @dev Deployment script for StakingHelperV2 contract
 * 
 * Environment variables needed in .env file:
 * - PRIVATE_KEY: Your deployer's private key
 * - RPC_URL: RPC endpoint URL (optional, can be passed via --rpc-url flag)
 * 
 * Usage:
 * forge script script/DeployStakingHelper.s.sol:DeployStakingHelper --rpc-url $RPC_URL --broadcast
 * 
 * Or if you have RPC_URL in .env:
 * forge script script/DeployStakingHelper.s.sol:DeployStakingHelper --broadcast
 */
contract DeployStakingHelperV2 is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        StakingHelperV2 receiver = new StakingHelperV2();
        console.log("StakingHelperV2 deployed at:", address(receiver));
        vm.stopBroadcast();
    }

} 