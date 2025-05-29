# HookMagic - Superfluid Staking Automation

HookMagic is a Superfluid-based automation system that enables users to automatically stake multiple ERC777 tokens through a single batch transaction. The system consists of staking helpers that receive tokens and automatically stake them, and macros that batch multiple operations for gas efficiency.

## 🏗️ Architecture

### Core Components

1. **StakingHelperV2** - ERC777 token receiver that automatically stakes received tokens
2. **StakingMacroV2** - Superfluid macro that batches token sends and pool connections
3. **IStakingHelper** - Interface defining the staking helper contract structure

### Key Features

- **Batch Operations**: Send multiple tokens and connect to distribution pools in a single transaction
- **Automatic Staking**: Tokens sent to the helper are automatically staked
- **Pool Management**: Automatically connects users to Superfluid distribution pools
- **Gas Optimization**: Reduces transaction costs through batching

## 📋 Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Node.js (for package management)
- Access to Base network RPC

## 🚀 Quick Start

### 1. Clone and Setup

```bash
git clone <repository-url>
cd HookMagic
forge install
```

### 2. Environment Configuration

Create a `.env` file:

```bash
PRIVATE_KEY=your_private_key_here
RPC_URL=https://mainnet.base.org
BASE_MAINNET_RPC_URL=https://mainnet.base.org
BASE_SEPOLIA_RPC_URL=https://sepolia.base.org
BASESCAN_API_KEY=your_basescan_api_key
```

### 3. Build the Project

```bash
forge build
```

### 4. Run Tests

```bash
# Run all tests
forge test

# Run specific test file
forge test --match-path test/FullTest.sol

# Run with verbose output
forge test -vvvv
```

## 📦 Deployment

### Deploy All Contracts

```bash
# Deploy to Base Mainnet
forge script script/DeployAll.sol:DeployAll --rpc-url $BASE_MAINNET_RPC_URL --broadcast --verify

# Deploy to Base Sepolia (Testnet)
forge script script/DeployAll.sol:DeployAll --rpc-url $BASE_SEPOLIA_RPC_URL --broadcast --verify
```

### Deploy Individual Components

```bash
# Deploy StakingHelperV2 only
forge script script/DeployStakingHelperV2.sol:DeployStakingHelperV2 --rpc-url $RPC_URL --broadcast

# Deploy StakingMacroV2 only (requires existing StakingHelper address)
forge script script/DeployStakingMacroV2.sol:DeployStakingMacroV2 --rpc-url $RPC_URL --broadcast
```

## 🌐 Deployed Addresses (Base Mainnet)

### Core Contracts
- **StakingHelperV2**: `0x1738e0Fed480b04968A3B7b14086EAF4fDB685A3`
- **StakingMacroV2**: `0x5c4b8561363E80EE458D3F0f4F14eC671e1F54Af`

### Superfluid Infrastructure
- **MacroForwarder**: `0xFD0268E33111565dE546af2675351A4b1587F89F` (Universal)
- **GDA (General Distribution Agreement)**: `0xfE6c87BE05feDB2059d2EC41bA0A09826C9FD7aa`
- **ERC1820 Registry**: `0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24` (Universal)

### Supported Tokens
- **STREME**: `0x3B3Cd21242BA44e9865B066e5EF5d1cC1030CC58`
- **FLUD**: `0x115e4F668d441238D6E1Fc0Db25d74Ad0959B9C7`
- **NOIN0**: `0x13a97D5AE4B2637CfBCcf3496f7FC31722e68821`
- **NAGARE**: `0x003e0BFf75ADd462A1B606Db97Bf9ba58056d073`

## 🔧 Usage

### Using the Macro (Recommended)

The macro allows you to stake multiple tokens in a single transaction:

```bash
# Run the macro with your tokens
forge script script/TryMacro.sol:TryMacro --rpc-url $RPC_URL --broadcast
```

### Direct Token Sending

You can also send tokens directly to the StakingHelper:

```bash
# Send tokens directly
forge script script/SendTokens.sol:SendTokens --rpc-url $RPC_URL --broadcast
```

### Using Cast Commands

```bash
# Check token balance
cast call $TOKEN_ADDRESS "balanceOf(address)" $YOUR_ADDRESS --rpc-url $RPC_URL

# Send tokens to staking helper
cast send $TOKEN_ADDRESS "send(address,uint256,bytes)" $STAKING_HELPER_ADDRESS $AMOUNT "0x" --private-key $PRIVATE_KEY --rpc-url $RPC_URL

# Check staking contract for a token
cast call $STAKING_HELPER_ADDRESS "getStakingContract(address)" $TOKEN_ADDRESS --rpc-url $RPC_URL
```

## 🧪 Testing

### Fork Testing

The project includes comprehensive fork tests that run against real network state:

```bash
# Run fork tests
forge test --match-path test/FullTest.sol --fork-url $RPC_URL -vvvv

# Run specific test
forge test --match-test testSendViaMacro --fork-url $RPC_URL -vvvv
```

### Test Structure

- `test/FullTest.sol` - Comprehensive fork tests for the complete system
- Tests cover both direct token sending and macro-based batch operations
- Includes balance verification and staking confirmation

## 📁 Project Structure

```
HookMagic/
├── src/
│   ├── StakingHelperV2.sol      # Main staking helper contract
│   ├── StakingMacroV2.sol       # Superfluid macro for batching
│   ├── StakingHelper.sol        # Legacy staking helper
│   ├── StakingMacro.sol         # Legacy macro
│   └── interfaces/
│       └── IStakingHelper.sol   # Staking helper interface
├── script/
│   ├── DeployAll.sol            # Deploy all contracts
│   ├── DeployStakingHelperV2.sol
│   ├── DeployStakingMacroV2.sol
│   ├── TryMacro.sol            # Test macro execution
│   ├── SendTokens.sol          # Direct token sending
│   └── tokens.json             # Token metadata
├── test/
│   └── FullTest.sol            # Comprehensive fork tests
└── foundry.toml                # Foundry configuration
```

## 🔍 How It Works

### 1. Token Reception
- Users send ERC777 tokens to `StakingHelperV2`
- The contract automatically receives tokens via `tokensReceived` hook
- Tokens are immediately staked in their respective staking contracts

### 2. Macro Batching
- `StakingMacroV2` creates batch operations for multiple tokens
- Checks user balances and creates send operations
- Automatically connects users to distribution pools if needed
- Executes all operations in a single transaction via `MacroForwarder`

### 3. Staking Integration
- Each supported token has a corresponding staking contract
- Staking contracts are either pre-configured or predicted via factory
- Staked tokens earn rewards through Superfluid distribution pools

## 🛠️ Development

### Adding New Tokens

1. Deploy or identify the staking contract for the new token
2. Call `storePairs()` on `StakingHelperV2` to add the token-staking pair
3. Update test files with new token addresses

### Modifying the Macro

The macro logic is in `buildBatchOperations()` in `StakingMacroV2.sol`. Key considerations:
- Always initialize arrays with proper sizes
- Use consistent struct initialization syntax
- Handle edge cases (zero balances, missing staking contracts)

## 🔐 Security Considerations

- All contracts use OpenZeppelin's battle-tested implementations
- ERC1820 registry integration for proper ERC777 support
- Owner-only functions for critical operations
- Comprehensive testing on fork environments

## 📚 Dependencies

- **OpenZeppelin Contracts**: Standard implementations for ERC777, access control
- **Superfluid Protocol**: Core streaming and distribution functionality
- **Foundry**: Development framework and testing

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add comprehensive tests
4. Ensure all tests pass: `forge test`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For questions and support:
- Check the test files for usage examples
- Review Superfluid documentation for macro development
- Ensure proper environment configuration before deployment
