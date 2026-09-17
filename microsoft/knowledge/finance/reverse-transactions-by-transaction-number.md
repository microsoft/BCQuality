---
bc-version: [all]
domain: finance
keywords: [reversetransaction, reverseregister, transaction-no, entry-no, reversal-entry, g-l-register]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Pass the transaction number, not a ledger-entry number, to ReverseTransaction

## Description

`Reversal Entry.ReverseTransaction` expects a **transaction number**, while `ReverseRegister` expects a **G/L register number**. Neither parameter means a ledger `Entry No.`. All are integers, so the compiler accepts the wrong identity; a coincidentally matching integer can select another transaction instead of the posting the user intended to reverse.

## Best Practice

When starting from a `G/L Entry`, fetch that entry and pass **its** `Transaction No.` to `Reversal Entry.ReverseTransaction`, as the sample does. The same identity distinction applies to customer/vendor ledger entries when using their supported transaction-reversal path. If the starting point is a G/L register, use `Reversal Entry.ReverseRegister` with that register's number. The interactive workflow collects the participating entries and validates reversal eligibility before the user posts the reversal.

Do not infer eligibility from `Open` alone or bypass a rejection by changing origin, application, or reversal fields. The supported path depends on source and state; some postings require unapplication or a correcting document first. A request to reverse is not a guarantee that reversal will be permitted. This rule concerns the two named `Reversal Entry` APIs, not routines such as `UnApplyCustLedgEntry` that legitimately accept a ledger entry number.

See sample: [`reverse-transactions-by-transaction-number.good.al`](reverse-transactions-by-transaction-number.good.al).

## Anti Pattern

Pass a ledger entry's `Entry No.` or a register number into `ReverseTransaction`, or pass a ledger-entry/transaction number into `ReverseRegister`. Require visible value provenance, not merely a suspicious variable name or an arbitrary integer. A correctly sourced transaction number is valid even when the variable is poorly named.

See sample: [`reverse-transactions-by-transaction-number.bad.al`](reverse-transactions-by-transaction-number.bad.al).

## References

- [Reversal Entry API](https://learn.microsoft.com/en-us/dynamics365/business-central/application/base-application/table/microsoft.finance.generalledger.reversal.reversal-entry).
- [Reverse journal postings](https://learn.microsoft.com/en-us/dynamics365/business-central/finance-how-reverse-journal-posting).
- [BCApps: reversal entry selection](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Finance/GeneralLedger/Reversal/ReversalEntry.Table.al).
