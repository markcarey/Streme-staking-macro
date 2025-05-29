// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/StakingHelperV2.sol";
import "../src/StakingMacroV2.sol";
import "../src/interfaces/IStakingHelper.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/introspection/IERC1820Registry.sol";
import { MacroForwarder } from "@superfluid-finance/contracts/utils/MacroForwarder.sol";

contract StakingHelperForkTest is Test {
    StakingHelperV2 public stakingHelper;
    StakingMacroV2 public macroContract;
    // STREME tokens from deployment script
    IERC777 public constant STREME = IERC777(0x3B3Cd21242BA44e9865B066e5EF5d1cC1030CC58);
    IERC777 public constant FLUD = IERC777(0x115e4F668d441238D6E1Fc0Db25d74Ad0959B9C7);
    IERC777 public constant NOIN0 = IERC777(0x13a97D5AE4B2637CfBCcf3496f7FC31722e68821);
    IERC777 public constant NAGARE = IERC777(0x003e0BFf75ADd462A1B606Db97Bf9ba58056d073);
    address[] public tokens = new address[](4);

    // We'll need to find whale addresses for these tokens or use different approach
    address public user = address(0xf8a025B42B07db05638FE596cce339707ec3cC71);
    address public owner;
    
    address macroForwarder = 0xFD0268E33111565dE546af2675351A4b1587F89F; //same on every network
    IERC1820Registry constant ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    
    function setUp() public {
        // Fork mainnet at a recent block
        vm.createFork(vm.envString("RPC_URL"));
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // calculate address from private key
        address deployer = vm.addr(deployerPrivateKey);
        // Set owner for the StakingHelper
        owner = deployer;
        
        vm.startPrank(deployer);
        // save StakingHelper
        stakingHelper = new StakingHelperV2();//(0x45c01d1A5ed37DbE6b90d519756660856f9c1946);
        macroContract = new StakingMacroV2(address(stakingHelper)); // StakingMacroV2(0xD6d0d9D4D512805675C99A2978C03B47DFa10Adf);

        // Set up token-staking contract pairs using the same addresses as deployment script
        tokens[0] = address(STREME);
        tokens[1] = address(FLUD);
        tokens[2] = address(NOIN0);
        tokens[3] = address(NAGARE);

        vm.stopPrank();
        // Label addresses for better trace output
        vm.label(address(STREME), "STREME");
        vm.label(address(FLUD), "FLUD");
        vm.label(address(NOIN0), "NOIN0");
        vm.label(address(NAGARE), "NAGARE");
        vm.label(address(stakingHelper), "StakingHelperV2");
        vm.label(address(macroForwarder), "MacroForwarder");
        vm.label(address(ERC1820_REGISTRY), "ERC1820Registry");
        console.log("block.timestamp:", block.timestamp);
    }
    
    function testForkConstructor() public view {
        // Test that the receiver is properly registered with ERC1820
        bytes32 interfaceHash = keccak256("ERC777TokensRecipient");
        address implementer = ERC1820_REGISTRY.getInterfaceImplementer(
            address(stakingHelper),
            interfaceHash
        );
        assertEq(implementer, address(stakingHelper));
    }

    function testSendDirectly() public {        
        uint256 userBalance = STREME.balanceOf(user);
        assertGt(userBalance, 0, "User should have STREME token balance");
        // check the staked balance too
        address stakingContract = stakingHelper.getStakingContract(address(STREME));
        uint256 stakedBalance = IERC20(stakingContract).balanceOf(user);
        // User sends tokens to stakingHelper
        vm.prank(user);
        STREME.send(address(stakingHelper), userBalance, "");
        
        // user balance of staked tokens should have increased by the original balance
        assertEq(IERC20(stakingContract).balanceOf(user), stakedBalance + userBalance);
        // now the balance should be zero
        assertEq(IERC20(address(STREME)).balanceOf(user), 0);
    }

    function testSendViaMacro() public {
        bytes memory params = macroContract.getParams(tokens);
        // first off, let's store the user's token balances for each token
        uint256[] memory balances = new uint256[](tokens.length);
        for (uint i = 0; i < tokens.length; i++) {
            balances[i] = IERC20(tokens[i]).balanceOf(user);
        }
        MacroForwarder(macroForwarder).runMacro(IUserDefinedMacro(address(macroContract)), params);

        // now we need to check that all the balances are zero again
        for (uint i = 0; i < tokens.length; i++) {
            assertEq(IERC20(tokens[i]).balanceOf(user), 0);
        }

        // now we send the time forward
        vm.warp(block.timestamp + 1000);
        // now we need to check that the balance is no longer zero
        for (uint i = 0; i < tokens.length; i++) {
            assertGt(IERC20(tokens[i]).balanceOf(user), 0);
        }
    }
}