pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/interfaces/IStakingHelper.sol";
import {ISuperToken} from "@superfluid-finance/contracts/interfaces/superfluid/ISuperfluid.sol";
import "forge-std/console.sol";
import {IERC777} from "@openzeppelin/contracts/token/ERC777/IERC777.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {StakingHelperV2} from "../src/StakingHelperV2.sol";
import {StakingMacroV2} from "../src/StakingMacroV2.sol";
import {MacroForwarder} from "@superfluid-finance/contracts/utils/MacroForwarder.sol";
import {IUserDefinedMacro} from "@superfluid-finance/contracts/interfaces/utils/IUserDefinedMacro.sol";

contract TryMacro is Script {

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        // get the deployer's address
        address deployer = vm.addr(deployerPrivateKey);
        console.log("Deployer's address:", deployer);
        
        // macro forwarder
        address macroForwarder = 0xFD0268E33111565dE546af2675351A4b1587F89F;
        
        
        address stakingHelper = 0x1738e0Fed480b04968A3B7b14086EAF4fDB685A3;
        // macro contract
        address macroContract = 0x5c4b8561363E80EE458D3F0f4F14eC671e1F54Af;

        // token list
        IERC777 STREME = IERC777(0x3B3Cd21242BA44e9865B066e5EF5d1cC1030CC58);
        IERC777 FLUD = IERC777(0x115e4F668d441238D6E1Fc0Db25d74Ad0959B9C7);
        IERC777 NOIN0 = IERC777(0x13a97D5AE4B2637CfBCcf3496f7FC31722e68821);
        IERC777 NAGARE = IERC777(0x003e0BFf75ADd462A1B606Db97Bf9ba58056d073);
        address[] memory tokens = new address[](4);
        tokens[0] = address(NAGARE);
        tokens[1] = address(FLUD);
        tokens[2] = address(NOIN0);
        tokens[3] = address(STREME);

        for (uint i = 0; i < tokens.length; i++) {
            console.log("Token address:", tokens[i]);
            console.log("token symbol:", IERC777(tokens[i]).symbol());
            console.log("Token balance:", IERC777(tokens[i]).balanceOf(deployer));
        }

        // staking token balances before macro
        for (uint i = 0; i < tokens.length; i++) {
            address stakingContract = StakingHelperV2(stakingHelper).getStakingContract(tokens[i]);
            console.log("Staking contract:", stakingContract);
            console.log("Staking token:", IERC777(tokens[i]).symbol());
            console.log("Staking balance:", IERC20(stakingContract).balanceOf(deployer));
        }

        // now call the macro contract
        // first encode the data
        console.log("calculating params");
        bytes memory params = StakingMacroV2(macroContract).getParams(tokens);
        console.log("params calculated");
        console.logBytes(params);
        console.log("passing params to macro forwarder");
        // then pass the params to the macro forwarder along with the macro contract address
        MacroForwarder(macroForwarder).runMacro(IUserDefinedMacro(macroContract), params);
        console.log("macro forwarder called");
        
        // token balances after macro
        for (uint i = 0; i < tokens.length; i++) {
            console.log("Token address:", tokens[i]);
            console.log("Token balance:", IERC777(tokens[i]).balanceOf(deployer));
        }

        // balance of staking tokens after macro
        for (uint i = 0; i < tokens.length; i++) {
            address stakingContract = StakingHelperV2(stakingHelper).getStakingContract(tokens[i]);
            console.log("Staking contract:", stakingContract);
            console.log("Staking balance:", IERC20(stakingContract).balanceOf(deployer));
        }

        vm.stopBroadcast();
    }

}