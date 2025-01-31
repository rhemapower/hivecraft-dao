# HiveCraft DAO Platform

A decentralized platform for creating and managing DAO communities on the Stacks blockchain.

## Features
- Create new DAOs with customizable parameters
- Manage membership and voting rights
- Submit and vote on proposals
- Execute approved proposals
- Treasury management
- Auto-incrementing DAO and proposal IDs
- Enhanced error handling and validation

## Contracts
- `dao-core.clar`: Core DAO functionality and governance
  - Automatic ID management for DAOs and proposals
  - Comprehensive error handling
  - Voting period and quorum validation
- `dao-treasury.clar`: Treasury and fund management
- `dao-token.clar`: Governance token implementation

## Usage
```clarity
;; Create a new DAO
(contract-call? .dao-core create-dao "My DAO" "Description" u100 u10)

;; Submit a proposal
(contract-call? .dao-core submit-proposal u1 "Proposal" "Description")

;; Vote on a proposal
(contract-call? .dao-core vote u1 true)

;; Execute an approved proposal
(contract-call? .dao-core execute-proposal u1)
```

## Testing
Run tests with: `clarinet test`
