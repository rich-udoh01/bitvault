# BitVault Protocol

> Bitcoin-Native Collateralized Lending Platform on Stacks

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Stacks](https://img.shields.io/badge/Built%20on-Stacks-blue)](https://stacks.org)
[![Clarity](https://img.shields.io/badge/Language-Clarity-purple)](https://clarity-lang.org)

## Overview

BitVault Protocol is an innovative DeFi lending ecosystem on Stacks that transforms Bitcoin holders into active DeFi participants through STX-collateralized borrowing with institutional-grade risk controls and automated position management.

The protocol bridges traditional Bitcoin holding with modern DeFi capabilities, enabling users to unlock liquidity from their STX holdings without selling. BitVault implements sophisticated collateral management, dynamic risk assessment, and community-driven liquidation mechanisms to create a sustainable lending marketplace.

### Key Features

- **STX Collateralized Lending**: Deposit STX as collateral to borrow against your holdings
- **Dynamic Risk Management**: Automated liquidation protection with configurable ratios
- **Capital Efficiency**: Unlock liquidity without selling your Bitcoin-adjacent assets
- **Institutional Grade**: Robust risk controls and predictable parameters
- **Community Liquidations**: Decentralized liquidation mechanism with incentives

## Architecture

### System Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     Users       │    │   BitVault      │    │   Liquidators   │
│                 │    │   Protocol      │    │                 │
│ • Deposit STX   │◄──►│                 │◄──►│ • Monitor       │
│ • Borrow STX    │    │ • Risk Engine   │    │   Positions     │
│ • Repay Loans   │    │ • Collateral    │    │ • Execute       │
│ • Withdraw      │    │   Management    │    │   Liquidations  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Contract Architecture

The BitVault Protocol consists of several key components:

#### 1. **Core State Management**

- **Risk Parameters**: Configurable collateral ratios and liquidation thresholds
- **Global Metrics**: Protocol-wide deposits, borrows, and utilization tracking
- **User Positions**: Individual collateral and debt position management

#### 2. **Data Structures**

```clarity
;; Individual Loan Records
loans: { loan-id: uint } → {
  borrower: principal,
  collateral-amount: uint,
  borrowed-amount: uint,
  interest-rate: uint,
  start-height: uint,
  last-interest-update: uint,
  active: bool
}

;; User Portfolio Tracking
user-positions: { user: principal } → {
  total-collateral: uint,
  total-borrowed: uint,
  loan-count: uint
}
```

#### 3. **Risk Management Engine**

- **Minimum Collateral Ratio**: Default 150% (configurable 110%-500%)
- **Liquidation Threshold**: Default 130% (must be ≤ minimum ratio)
- **Protocol Fee**: Default 1% (max 10%)

## Data Flow

### 1. Deposit Flow

```
User STX → Protocol Contract → Collateral Balance Update → Position Tracking
```

### 2. Borrow Flow

```
Borrow Request → Collateral Ratio Check → STX Transfer → Debt Position Update
```

### 3. Repayment Flow

```
STX Payment → Debt Reduction → Position Update → Collateral Ratio Improvement
```

### 4. Liquidation Flow

```
Position Monitor → Ratio < Threshold → Liquidator Call → Collateral Transfer → Position Closure
```

## Core Functions

### User Operations

#### `deposit()`

Deposits user's entire STX balance as collateral

- **Access**: Public
- **Effect**: Increases user's collateral position
- **Returns**: Amount deposited

#### `borrow(amount: uint)`

Borrows STX against deposited collateral

- **Parameters**: `amount` - STX amount to borrow
- **Validation**: Maintains minimum collateral ratio
- **Returns**: Amount borrowed

#### `repay(amount: uint)`

Repays borrowed STX to reduce debt

- **Parameters**: `amount` - STX amount to repay
- **Effect**: Reduces debt position
- **Returns**: Amount repaid

#### `withdraw(amount: uint)`

Withdraws collateral while maintaining safety ratios

- **Parameters**: `amount` - STX amount to withdraw
- **Validation**: Ensures minimum collateral ratio maintained
- **Returns**: Amount withdrawn

### Liquidation

#### `liquidate(user: principal)`

Liquidates undercollateralized positions

- **Parameters**: `user` - Address of position to liquidate
- **Trigger**: Collateral ratio < liquidation threshold
- **Effect**: Transfers collateral to liquidator, closes position
- **Access**: Public (community-driven)

### Read-Only Functions

#### `get-user-position(user: principal)`

Returns complete user position information

- **Returns**: Collateral, borrowed amounts, and loan count

#### `get-protocol-stats()`

Returns comprehensive protocol statistics

- **Returns**: Total deposits, borrows, and risk parameters

## Risk Parameters

| Parameter | Default | Range | Description |
|-----------|---------|-------|-------------|
| Minimum Collateral Ratio | 150% | 110%-500% | Required overcollateralization |
| Liquidation Threshold | 130% | 110%-MCR | Liquidation trigger point |
| Protocol Fee | 1% | 0%-10% | Revenue fee on operations |

## Security Features

### 1. **Access Controls**

- Contract owner restrictions on parameter updates
- User-specific position management
- Liquidator validation checks

### 2. **Risk Validation**

- Collateral ratio enforcement on all operations
- Parameter bounds checking
- Overflow protection with safe arithmetic

### 3. **State Consistency**

- Atomic position updates
- Global metric synchronization
- Error handling with descriptive codes

## Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) for development
- [Stacks Wallet](https://wallet.hiro.so) for interaction
- STX tokens for collateral

### Development Setup

1. **Clone the repository**

   ```bash
   git clone https://github.com/rich-udoh01/bitvault.git
   cd bitvault
   ```

2. **Install dependencies**

   ```bash
   npm install
   ```

3. **Run tests**

   ```bash
   clarinet test
   ```

4. **Check contracts**

   ```bash
   clarinet check
   ```

### Deployment

Deploy to Stacks testnet:

```bash
clarinet deploy --testnet
```

## Usage Examples

### Basic Lending Flow

```javascript
// 1. Deposit STX as collateral
await callPublicFunction({
  contractAddress: 'SP123...BITVAULT',
  contractName: 'bitvault',
  functionName: 'deposit',
  functionArgs: [],
  senderKey: userPrivateKey
});

// 2. Borrow against collateral
await callPublicFunction({
  contractAddress: 'SP123...BITVAULT',
  contractName: 'bitvault',
  functionName: 'borrow',
  functionArgs: [uintCV(1000000)], // 1 STX
  senderKey: userPrivateKey
});

// 3. Repay loan
await callPublicFunction({
  contractAddress: 'SP123...BITVAULT',
  contractName: 'bitvault',
  functionName: 'repay',
  functionArgs: [uintCV(1000000)], // 1 STX
  senderKey: userPrivateKey
});
```

## Error Codes

| Code | Error | Description |
|------|-------|-------------|
| u100 | ERR-NOT-AUTHORIZED | Insufficient permissions |
| u101 | ERR-INSUFFICIENT-COLLATERAL | Collateral ratio too low |
| u102 | ERR-INVALID-AMOUNT | Invalid operation amount |
| u103 | ERR-LOAN-NOT-FOUND | Position does not exist |
| u104 | ERR-LOAN-ACTIVE | Cannot modify active loan |
| u105 | ERR-INSUFFICIENT-BALANCE | Insufficient account balance |
| u106 | ERR-LIQUIDATION-FAILED | Liquidation conditions not met |
| u107 | ERR-INVALID-PARAMETER | Parameter out of valid range |

## Testing

Run the comprehensive test suite:

```bash
# Run all tests
npm test

# Check contract syntax
clarinet check

# Run specific test file
clarinet test tests/bitvault.test.ts
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Roadmap

- [ ] **Phase 1**: Core lending functionality (Current)
- [ ] **Phase 2**: Interest rate models and yield optimization
- [ ] **Phase 3**: Multi-asset collateral support
- [ ] **Phase 4**: Governance token and DAO integration
- [ ] **Phase 5**: Cross-chain Bitcoin integration

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
