// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/StakingHelper.sol";
import "../src/interfaces/IStakingHelper.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/introspection/IERC1820Registry.sol";

contract MockStakingContract {
    event Deposit(address indexed to, uint256 amount);
    
    mapping(address => uint256) public deposits;
    
    function deposit(address to, uint256 amount) external {
        deposits[to] += amount;
        emit Deposit(to, amount);
    }
}

contract StakingHelperForkTest is Test {
    IStakingHelper public stakingHelper;
    MockStakingContract public stremeStakingContract1;
    MockStakingContract public stremeStakingContract2;
    
    // STREME tokens from deployment script
    IERC777 public constant STREME_TOKEN_1 = IERC777(0x3B3Cd21242BA44e9865B066e5EF5d1cC1030CC58);
    address public constant STREME_STAKING_CONTRACT = 0x93419F1C0F73b278C73085C17407794A6580dEff;    
  
    // We'll need to find whale addresses for these tokens or use different approach
    address public user = address(0xf8a025B42B07db05638FE596cce339707ec3cC71);
    address public owner;
    
    IERC1820Registry constant ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    
    function setUp() public {
        // Fork mainnet at a recent block
        vm.createFork(vm.envString("MAINNET_RPC_URL"));
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // calculate address from private key
        address deployer = vm.addr(deployerPrivateKey);
        // Set owner for the StakingHelper
        owner = deployer;
        
        vm.startPrank(deployer);
        // save StakingHelper
        stakingHelper = IStakingHelper(0xB92f3694e7c747f5C10703ceD8F069238F31C37E);
        
        // Set up token-staking contract pairs using the same addresses as deployment script
        address[] memory tokens = new address[](1);
        tokens[0] = address(STREME_TOKEN_1);
        
        address[] memory stakingContracts = new address[](1);
        stakingContracts[0] = address(STREME_STAKING_CONTRACT); // Using mock for testing
        
        stakingHelper.storePairs(tokens, stakingContracts);
        vm.stopPrank();
        // Label addresses for better trace output
        vm.label(address(STREME_TOKEN_1), "STREME_TOKEN_1");
        vm.label(address(stakingHelper), "StakingHelper");
        vm.label(address(stremeStakingContract1), "StremeStakingContract1");
        vm.label(address(stremeStakingContract2), "StremeStakingContract2");
        vm.label(STREME_STAKING_CONTRACT, "RealStakingContract1");
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
    
    function testForkStorePairs() public {
        // Test that the pairs were stored correctly
        assertEq(stakingHelper.stakingContracts(address(STREME_TOKEN_1)), address(stremeStakingContract1));
    }
    
    function testForkDeploymentScriptConfiguration() public {
        // Test the exact configuration from the deployment script
        StakingHelper deploymentHelper = new StakingHelper();
        
        // Replicate the deployment script setup
        address[] memory tokens = new address[](2);
        tokens[0] = 0x3B3Cd21242BA44e9865B066e5EF5d1cC1030CC58;
        tokens[1] = 0x063eDA1b84ceaF79b8cC4a41658b449e8E1F9Eeb;

        address[] memory stakingContracts = new address[](2);
        stakingContracts[0] = 0x93419F1C0F73b278C73085C17407794A6580dEff;
        stakingContracts[1] = 0xC7F2329977339F4Ae003373D1ACb9717F9d0c6D5;

        deploymentHelper.storePairs(tokens, stakingContracts);
        
        // Verify the mapping is set correctly
        assertEq(deploymentHelper.stakingContracts(tokens[0]), stakingContracts[0]);
        assertEq(deploymentHelper.stakingContracts(tokens[1]), stakingContracts[1]);
    }

    function testForkStremeToken1Transfer() public {
        uint256 amount = 100 * 10**18; // Assuming 18 decimals for STREME tokens
        
        
        uint256 userBalance = IERC20(address(STREME_TOKEN_1)).balanceOf(user);
        assertGt(userBalance, 0, "User should have STREME token balance");
        
        // User sends tokens to stakingHelper
        vm.prank(user);
        STREME_TOKEN_1.send(address(stakingHelper), amount, "test data");
        
        // Verify that the deposit was recorded in the correct staking contract
        assertEq(stremeStakingContract1.deposits(user), amount);
        assertEq(stremeStakingContract2.deposits(user), 0); // Should be 0 for other contract
        
    }
}
    /*
    
    function testForkStremeToken2Transfer() public {
        uint256 amount = 200 * 10**18; // Assuming 18 decimals for STREME tokens
        
        // Give user some tokens
        deal(address(STREME_TOKEN_2), user, amount);
        
        uint256 userBalance = IERC20(address(STREME_TOKEN_2)).balanceOf(user);
        assertGt(userBalance, 0, "User should have STREME token balance");
        
        // Check if the token supports ERC777 interface
        if (IERC777(address(STREME_TOKEN_2)).supportsInterface(type(IERC777).interfaceId)) {
            // Expect the deposit function to be called on STREME staking contract
            vm.expectEmit(true, true, false, true);
            emit MockStakingContract.Deposit(user, amount);
            
            // User sends tokens to stakingHelper
            vm.prank(user);
            STREME_TOKEN_2.send(address(stakingHelper), amount, "test data");
            
            // Verify that the deposit was recorded in the correct staking contract
            assertEq(stremeStakingContract2.deposits(user), amount);
            assertEq(stremeStakingContract1.deposits(user), 0); // Should be 0 for other contract
        }
    }
    
    function testForkTokenMetadata() public {
        // Test token metadata if available
        try IERC20(address(STREME_TOKEN_1)).name() returns (string memory name) {
            console.log("STREME_TOKEN_1 name:", name);
        } catch {
            console.log("STREME_TOKEN_1 name not available");
        }
        
        try IERC20(address(STREME_TOKEN_1)).symbol() returns (string memory symbol) {
            console.log("STREME_TOKEN_1 symbol:", symbol);
        } catch {
            console.log("STREME_TOKEN_1 symbol not available");
        }
        
        try IERC20(address(STREME_TOKEN_1)).decimals() returns (uint8 decimals) {
            console.log("STREME_TOKEN_1 decimals:", decimals);
        } catch {
            console.log("STREME_TOKEN_1 decimals not available");
        }
    }
    
    function testForkUnsupportedToken() public {
        // Create a mock token that's not in the mapping
        address unsupportedToken = address(0x999);
        uint256 amount = 100 * 10**18;
        
        // Mock the token to have a transfer function and balance
        vm.mockCall(
            unsupportedToken,
            abi.encodeWithSelector(IERC20.transfer.selector, user, amount),
            abi.encode(true)
        );
        
        // Expect TokenNotSupported event
        vm.expectEmit(true, false, false, false);
        emit StakingHelper.TokenNotSupported(unsupportedToken);
        
        // Simulate tokensReceived call from unsupported token
        vm.prank(unsupportedToken);
        stakingHelper.tokensReceived(
            address(0),
            user,
            address(stakingHelper),
            amount,
            "",
            ""
        );
    }
    
    function testForkMultipleStremeTokens() public {
        uint256 amount1 = 100 * 10**18;  // STREME token 1
        uint256 amount2 = 200 * 10**18;  // STREME token 2
        
        // Give user both tokens
        deal(address(STREME_TOKEN_1), user, amount1);
        deal(address(STREME_TOKEN_2), user, amount2);
        
        // Check if tokens support ERC777 and send them
        if (IERC777(address(STREME_TOKEN_1)).supportsInterface(type(IERC777).interfaceId)) {
            vm.prank(user);
            STREME_TOKEN_1.send(address(stakingHelper), amount1, "");
        }
        
        if (IERC777(address(STREME_TOKEN_2)).supportsInterface(type(IERC777).interfaceId)) {
            vm.prank(user);
            STREME_TOKEN_2.send(address(stakingHelper), amount2, "");
        }
        
        // Deposits should be recorded in separate staking contracts
        assertEq(stremeStakingContract1.deposits(user), amount1);
        assertEq(stremeStakingContract2.deposits(user), amount2);
    }
    
    function testForkOnlyOwnerCanStorePairs() public {
        address[] memory tokens = new address[](1);
        tokens[0] = address(0x123);
        
        address[] memory stakingContracts = new address[](1);
        stakingContracts[0] = address(0x456);
        
        // Should revert when called by non-owner
        vm.prank(user);
        vm.expectRevert();
        stakingHelper.storePairs(tokens, stakingContracts);
        
        // Should succeed when called by owner
        stakingHelper.storePairs(tokens, stakingContracts);
        assertEq(stakingHelper.stakingContracts(address(0x123)), address(0x456));
    }
    
    function testForkTokenApproval() public {
        // Test that tokens are approved for spending by staking contracts
        uint256 allowance1 = IERC20(address(STREME_TOKEN_1)).allowance(
            address(stakingHelper),
            address(stremeStakingContract1)
        );
        assertEq(allowance1, type(uint256).max);
        
        uint256 allowance2 = IERC20(address(STREME_TOKEN_2)).allowance(
            address(stakingHelper),
            address(stremeStakingContract2)
        );
        assertEq(allowance2, type(uint256).max);
    }
    
    function testForkRealStakingContractAddresses() public {
        // Test that we can interact with the real staking contract addresses
        // This is more of an integration test to verify the addresses are valid
        
        // Check if the real staking contracts have code
        uint256 codeSize1;
        uint256 codeSize2;
        
        assembly {
            codeSize1 := extcodesize(STAKING_CONTRACT_1)
            codeSize2 := extcodesize(STAKING_CONTRACT_2)
        }
        
        console.log("Real staking contract 1 code size:", codeSize1);
        console.log("Real staking contract 2 code size:", codeSize2);
        
        // If they have code, they're likely deployed contracts
        if (codeSize1 > 0) {
            console.log("Real staking contract 1 is deployed");
        }
        if (codeSize2 > 0) {
            console.log("Real staking contract 2 is deployed");
        }
    }
    
    function testForkWithRealStakingContracts() public {
        // Test with the actual staking contracts from the deployment script
        StakingHelper realConfigHelper = new StakingHelper();
        
        // Use the exact same configuration as the deployment script
        address[] memory tokens = new address[](2);
        tokens[0] = 0x3B3Cd21242BA44e9865B066e5EF5d1cC1030CC58;
        tokens[1] = 0x063eDA1b84ceaF79b8cC4a41658b449e8E1F9Eeb;

        address[] memory stakingContracts = new address[](2);
        stakingContracts[0] = 0x93419F1C0F73b278C73085C17407794A6580dEff;
        stakingContracts[1] = 0xC7F2329977339F4Ae003373D1ACb9717F9d0c6D5;

        realConfigHelper.storePairs(tokens, stakingContracts);
        
        // Verify the configuration matches deployment script
        assertEq(realConfigHelper.stakingContracts(tokens[0]), stakingContracts[0]);
        assertEq(realConfigHelper.stakingContracts(tokens[1]), stakingContracts[1]);
        
        // Test token approvals
        assertEq(
            IERC20(tokens[0]).allowance(address(realConfigHelper), stakingContracts[0]),
            type(uint256).max
        );
        assertEq(
            IERC20(tokens[1]).allowance(address(realConfigHelper), stakingContracts[1]),
            type(uint256).max
        );
    }
} */