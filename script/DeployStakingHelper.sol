// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/StakingHelper.sol";
import {ISuperToken} from "@superfluid-finance/contracts/interfaces/superfluid/ISuperfluid.sol";
import "forge-std/console.sol";
import "../src/interfaces/IStakingHelper.sol";

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
        
        vm.startBroadcast(deployerPrivateKey);
        
        StakingHelper receiver = new StakingHelper();
        
        console.log("StakingHelper deployed at:", address(receiver));

        // Create dynamic arrays with proper checksummed addresses
        address[] memory tokens = new address[](2);
        tokens[0] = 0x3B3Cd21242BA44e9865B066e5EF5d1cC1030CC58;
        tokens[1] = 0x063eDA1b84ceaF79b8cC4a41658b449e8E1F9Eeb;

        address[] memory stakingContracts = new address[](2);
        stakingContracts[0] = 0x93419F1C0F73b278C73085C17407794A6580dEff;
        stakingContracts[1] = 0xC7F2329977339F4Ae003373D1ACb9717F9d0c6D5;

        receiver.storePairs(tokens, stakingContracts);
        console.log("StakingHelper updated with pairs for all tokens");

        vm.stopBroadcast();
    }


} 