# Agent Badge

A free soulbound NFT badge for Agent ID holders on BNB Chain.

**Built for the Binance Agent ID Hackathon** (Submission: 18 Nov – 9 Dec 2026).

## What it is

Agent Badge is a minimal smart contract on BNB Chain. Any address that holds an
Agent ID can:

1. **Claim one free soulbound badge** — an ERC-721 NFT that can never be
   transferred, sold, or approved away. One badge per address, forever.
2. **Register an agent profile** — a display name (max 64 bytes) and an
   endpoint URL (max 200 bytes), stored on-chain and readable by anyone.

The claim is free. The holder pays only the gas for their own transaction.
There is no token, no fee, no payment, and no sale.

## How Agent ID is used

The contract reads the Agent ID contract on BNB Chain
(`0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F`, SPACE ID, ERC-721,
non-transferable) and requires `balanceOf(caller) > 0` before `claim()` or
`registerProfile()` can run. Addresses without an Agent ID revert with
`"not an Agent ID holder"`. Agent ID is the access-control gate for the whole
product — not an add-on.

## Contract

- **Source:** `src/AgentBadge.sol` (Solidity 0.8.26, optimizer on, 200 runs)
- **Name:** `Agent Badge` — **Symbol:** `ABADGE`
- **Network:** BNB Chain (chain id 56)
- **Agent ID contract:** `0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F`

### Functions

| Function | Who can call | What it does |
|---|---|---|
| `claim()` | Agent ID holder, once | Mints badge id N (starts at 1) to the caller |
| `registerProfile(string name, string endpoint)` | Agent ID holder | Sets/updates the caller's profile |
| `profileName(address)` / `profileEndpoint(address)` / `hasClaimed(address)` | anyone (view) | Reads a holder's profile |
| `balanceOf(address)` / `ownerOf(uint256)` / `totalSupply()` | anyone (view) | Standard ERC-721 reads |
| `supportsInterface(bytes4)` | anyone (view) | ERC-165: ERC-721 (`0x80ac58cd`) |

All transfer and approval functions (`transferFrom`, `safeTransferFrom`,
`approve`, `setApprovalForAll`) revert — the badge is soulbound.

### Owner permissions — disclosed

**This contract has NO owner and NO privileged functions.**

- There is no `owner` variable, no `onlyOwner` modifier, no `mint` by the
  deployer, no pause, no freeze, no tax, no fee, no upgrade, and no way to
  withdraw funds (the contract holds no funds and accepts none).
- The Agent ID contract address is set once in the constructor (immutable)
  and can never be changed.
- The deployer has exactly the same rights as any other address after
  deployment: none.

### Gas

Deploy (measured with `forge script`, local simulation): **874,039 gas**.
At the 0.05 gwei gas price seen on BSC at build time that is ~0.0000437 BNB.

### Tests

`forge test` — 8 tests, all passing:

- non-Agent-ID address cannot claim or register a profile (reverts)
- Agent ID holder can claim once; a second claim reverts
- all transfer / approval entry points revert (soulbound)
- profile registration works, updates work, validation reverts on bad input
- metadata (`name`, `symbol`, ERC-165 interface ids) is correct

Run them with:

```shell
forge test
```

Build with:

```shell
forge build
```

## How to claim (for Agent ID holders)

1. Open the project website (link in the repo / hackathon submission).
2. Connect the wallet that holds your Agent ID.
3. Click **Claim Badge** and confirm the transaction in your wallet.
   You pay only the gas.
4. Optionally set your agent name and endpoint URL with **Register Profile**.

## Verification

- Flattened source for BscScan verification: `flattened/AgentBadge.flattened.sol`
- Compiler: solc 0.8.26, optimizer enabled (200 runs), EVM version Cancun.
- License: MIT.

## Links

- Website: https://agentbadge.pages.dev/ (deployed after the contract goes live)
- Hackathon: Binance Agent ID Hackathon — 60,000 USDC prize pool.

## License

MIT. See `LICENSE`.
