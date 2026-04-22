---
bc-version: [1..99]
domain: finance
keywords: [exchange-rate, adjust-exchange-rate, report-595, detailed-ledger-entry, unrealized-gain-loss]
technologies: [al]
countries: [w1]
application-area: [finance]
---

# Exchange rate adjustment

## Description

Open foreign-currency ledger entries accumulate unrealized gain or loss as the exchange rate drifts from the posting-date rate. Report 595 (`Adjust Exchange Rates`) is the period-end batch job that revalues every open customer, vendor, bank, and G/L entry against the rate at the adjustment date. For each entry, it computes the rate delta, posts a Detailed Cust./Vendor Ledger Entry (or G/L Entry for bank and G/L accounts) that brings the LCY value back in line, and posts the offset to the configured Unrealized Gains/Unrealized Losses account. The next run reverses the prior adjustment before posting a new one, so the unrealized accounts only ever carry the current-period difference.

Running this batch is the hinge between period-end reporting and correct FCY balances. Skipping a period leaves the LCY equivalent of open balances stale; the next run has to absorb two periods of drift into one, producing a large unrealized swing that auditors flag. Running it twice in the same period on the same data is safe — the reversal mechanism makes the operation idempotent as long as the rate table has not changed.

## Best Practice

Schedule the batch as part of the month-end close, after posting the last FCY transactions and before freezing the period. Store the Exchange Rate table values the batch used so that re-running against "today's rates" later can be reconciled against the month-end snapshot.

## Anti Pattern

Running the batch without first verifying that the Currency Exchange Rate table has entries for the adjustment date. BC silently uses the most recent earlier entry, which on a missing-rate day can be weeks stale and produces an unrealized swing with no economic meaning.

## Provenance

Migrated from microsoft/BCAppsTriage's `plugins/triage/skills/triage/references/area-knowledge/finance.md` (section: "Multi-Currency — Rounding and Exchange Rates") on 2026-04-21.
