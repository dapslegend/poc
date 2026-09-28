# Withdrawal-queue denial of service — lab PoC

**Author:** Ayodapo Adesiyan (`dapslegend`)  
**Role:** Senior Cybersecurity Engineer  
**Class:** resource exhaustion / invalid-index processing on a withdrawal permit path  
**Status:** lab only. No mainnet calls. No live deployment.

This repository is a **defensive proof**. It shows why an unbounded withdrawal-request loop plus an owner permit over a large invalid-index list can stall or revert a contract, and what a senior review expects before the issue is closed.

The harness is [`poc.sol`](poc.sol). It is not an exploit kit. It does not broadcast transactions.

---

## Executive summary

| Item | Detail |
|---|---|
| Asset | `IFundingRateArbitrage` withdrawal queue (`requestWithdraw`, `permitWithdrawRequests`) |
| Actor | Unprivileged caller for request spam; privileged owner for the permit call |
| Bug | No cap on request count; `permitWithdrawRequests` walks a caller-sized `uint256[]` of indices, including intentionally invalid ones |
| Impact | Gas exhaustion or revert on the permit path. Queue processing can be stalled. Not a silent fund theft by itself |
| Severity (lab) | Medium if the permit path is permissioned but unbounded; High only if an unprivileged caller can force the same loop on a production queue that blocks withdrawals |
| Fix | Bound array length, reject unknown IDs before the loop, and add a regression test that a 5_000-id invalid list reverts cheaply |

Do not treat a title that says “PoC” as a confirmed critical. Confirm the production function, the access control, and a measured revert or gas spike on a **fork**.

---

## Threat model

- **In scope:** local or testnet deployment of a contract that implements the interface below. Replace the target address yourself. Do not point this at a mainnet address from this repo.
- **Out of scope:** broadcasting, draining user funds, phishing, or running this against a system you do not own or do not have written permission to test.
- **Trust boundary:** `requestWithdraw` is an external state-changing call. `permitWithdrawRequests` is an owner/operator path that must still be bounded — privileged code is not exempt from gas DoS.

```solidity
interface IFundingRateArbitrage {
    function requestWithdraw(uint256 repayJUSDAmount) external returns (uint256 withdrawEarnUSDCAmount);
    function permitWithdrawRequests(uint256[] memory requestIDList) external;
}
```

---

## Lab steps

1. Deploy the real target (or a stub with the same interface) on a **local fork or testnet**.
2. Deploy `FundingRateArbitragePOC` with that address.
3. Call `createMultipleWithdrawalRequests(n)` with a small `n` first (for example 8), not 1000, and record gas.
4. Call `submitInvalidIndices(n)` with the same small `n`. Indices are `i + 1000` so they are not real request IDs.
5. Increase `n` only until you can show the permit call reverts or gas grows linearly. Stop. That measurement is the finding.
6. Apply the fix on the target, rerun step 5, and show the call reverts in a bounded check **before** the heavy loop.

The old comment suggested `submitInvalidIndices(5000)` and 1000 withdrawal requests. That is a stress hint, not a required run. A senior writeup uses the smallest `n` that proves unbounded work.

---

## What “fixed” means

A fix is not “the PoC no longer compiles.”

- Reject `requestIDList.length` above a documented cap (or process in explicit batches).
- Resolve each ID; if it is unknown, revert with a named error **before** external calls or heavy storage writes.
- Regression: `submitInvalidIndices` with a large invalid list must fail closed and must not walk the full list doing storage writes.
- Re-measure gas on the same fork. If the owner path still scales with attacker-chosen length, the class is not closed.

---

## Files

| File | Purpose |
|---|---|
| [`poc.sol`](poc.sol) | Minimal harness. Constructor takes the lab target. Two functions: create requests, submit invalid indices |
| `README.md` | Scope, impact, lab steps, and the closure bar |

---

## Disclaimer

Educational and authorized security research only. You are responsible for where you deploy this. The author does not operate the target and does not authorize use against third-party systems.
