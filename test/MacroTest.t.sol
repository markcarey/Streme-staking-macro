// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "forge-std/Test.sol";
import { StakingMacro } from "../src/StakingMacro.sol";
import { MacroForwarder } from "@superfluid-finance/contracts/utils/MacroForwarder.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { console } from "forge-std/console.sol";
import { IUserDefinedMacro } from "@superfluid-finance/contracts/interfaces/utils/IUserDefinedMacro.sol";
contract MacroTest is Test {
    address public macroContract;

    address macroForwarder = 0xFD0268E33111565dE546af2675351A4b1587F89F; //same on every network
    // Create dynamic arrays with proper checksummed addresses
    address token1 = 0x3B3Cd21242BA44e9865B066e5EF5d1cC1030CC58;
    address token2 = 0x063eDA1b84ceaF79b8cC4a41658b449e8E1F9Eeb;

    address stakingContract1 = 0x93419F1C0F73b278C73085C17407794A6580dEff;
    address stakingContract2 = 0xC7F2329977339F4Ae003373D1ACb9717F9d0c6D5;

    function setUp() public {
        vm.createSelectFork(vm.envString("RPC_URL"));
        macroContract = address(new StakingMacro());
    }

    function test_buildBatchOperations() public {
        // impersonate my 771 account
        address user = 0xf8a025B42B07db05638FE596cce339707ec3cC71;
        vm.startPrank(user);

        // check balance of tokens
        uint256 balance1 = IERC20(token1).balanceOf(0xf8a025B42B07db05638FE596cce339707ec3cC71);
        uint256 balance2 = IERC20(token2).balanceOf(0xf8a025B42B07db05638FE596cce339707ec3cC71);
        console.log("Balance of token 1:", balance1);
        console.log("Balance of token 2:", balance2);
        // now we can call the macro
        address[] memory tokens = new address[](2); 
        tokens[0] = token1;
        tokens[1] = token2;


        bytes memory params = StakingMacro(macroContract).getParams(tokens);
        MacroForwarder(macroForwarder).runMacro(IUserDefinedMacro(macroContract), params);

        // check balance of tokens again
        balance1 = IERC20(token1).balanceOf(0xf8a025B42B07db05638FE596cce339707ec3cC71);
        balance2 = IERC20(token2).balanceOf(0xf8a025B42B07db05638FE596cce339707ec3cC71);
        console.log("Balance of token 1:", balance1);
        console.log("Balance of token 2:", balance2);

        uint256 stbalance1 = IERC20(stakingContract1).balanceOf(user);
        uint256 stbalance2 = IERC20(stakingContract2).balanceOf(user);
        console.log("Balance of staking contract 1:", stbalance1);
        console.log("Balance of staking contract 2:", stbalance2);
        
    }
}