# Wild bug PoCs

**Ayodapo Adesiyan** (`dapslegend`)

I write PoCs of wild bugs in the wild. This repo is the public lab note, not a weaponized kit and not an Immunefi report template.

`poc.sol` is one case: a withdrawal queue that accepts an unbounded list of invalid indices. On a system I was allowed to test, that path can stall permit processing. It is a gas / denial-of-service class. It is not a silent drain by itself.

## This file

| File | What it is |
|---|---|
| `poc.sol` | Small harness. Points at a lab target you deploy. Does not broadcast. |
| `README.md` | What the wild bug was, and what "fixed" means |

## The bug, in one paragraph

`requestWithdraw` can be called in a loop. `permitWithdrawRequests` then walks a caller-sized `uint256[]`. Feeding it indices that were never created (`i + 1000`) makes the owner path do work proportional to attacker-chosen length. In the wild that shows up as a permit/withdraw path that reverts or burns gas until the queue is unusable.

## What I do not claim

- Not every deployment of this interface is vulnerable. Confirm the function and the access control on a fork you control.
- A comment that says "try 5000" is a stress hint. The writeup uses the smallest `n` that shows linear work.
- No mainnet transactions from this repo.

## Closure

Bound `requestIDList.length`. Reject unknown IDs before storage writes. Rerun the same invalid-index list and show the call fails closed without walking the full list.

## Run (lab only)

Deploy a stub or the real target on a local fork or a testnet you control. Deploy `FundingRateArbitragePOC` with that address. Call `createMultipleWithdrawalRequests` and `submitInvalidIndices` with a small `n`. Record gas. Stop when the curve is obvious.

Authorized testing only. You are responsible for the target you point this at.
