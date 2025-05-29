// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/StakingHelper.sol";

/**
 * @title DeployStakingHelper
 * @dev Deployment script for StakingHelper contract
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
contract DeployStakingHelper is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address stakingFactory = vm.envAddress("STAKING_FACTORY_ADDRESS");
        
        vm.startBroadcast(deployerPrivateKey);
        
        StakingHelper receiver = new StakingHelper(stakingFactory);
        
        vm.stopBroadcast();
        
        console.log("StakingHelper deployed at:", address(receiver));
        console.log("Staking Factory address:", stakingFactory);

        address streme = 0x3b3cd21242ba44e9865b066e5ef5d1cc1030cc58;
        address stStreme = 0x93419f1c0f73b278c73085c17407794a6580deff;
        address superInu = 0x063eda1b84ceaf79b8cc4a41658b449e8e1f9eeb;
        address stSuperInu = 0xc7f2329977339f4ae003373d1acb9717f9d0c6d5;
        // call storePairs for all of these tokens
        receiver.storePairs([streme, superInu], [stStreme, stSuperInu]);
        console.log("StakingHelper updated with pairs for all tokens");
    }
} 