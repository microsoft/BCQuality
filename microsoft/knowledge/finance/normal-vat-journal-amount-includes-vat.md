---
bc-version: [all]
domain: finance
keywords: [normal-vat, automatic-vat-entry, gross-amount, net-amount, vat-posting-setup, gen-journal-line, purchase]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Supply a VAT-inclusive journal Amount for automatic Normal VAT

## Description

For a general-journal line using **Automatic VAT Entry** and **Normal VAT**, `Amount` includes VAT. The posting engine extracts tax from that total; it does not add tax to a VAT-exclusive expense imported into `Amount`. An LCY invoice with net 100 and VAT 25 therefore needs a journal total of 125, not 100.

## Best Practice

Map the source's VAT-inclusive total to journal `Amount` in this posting mode. Establish the intended account and posting-group combination before validating the final amount. Account-derived VAT defaults depend on `Copy VAT Setup to Jnl. Lines`; do not assume account selection always supplies the intended configuration.

Require the actual input contract and calculation mode, not just a variable named `NetAmount`. The examples encode source net, VAT, and gross values plus a 25% Normal-VAT setup check. They target an LCY G/L purchase with 0.01 amount rounding and without balancing-side VAT, additional reporting currency, VAT differences, or unrealized VAT. Other calculation types, Manual VAT Entry, reverse charge, Full VAT, sales/use tax, unrealized tax, and other currency/rounding contexts need their own analysis; this is not a universal gross-up formula or country-specific tax advice.

The concern is the supplied transaction total, not its deductible/non-deductible allocation. Non-deductible VAT features can change the allocation of that total, not turn the source's net amount into its gross amount. Do not infer a particular expense or deductible-VAT split from this rule. The samples therefore do not depend on later-version non-deductible-VAT fields.

See sample: [`normal-vat-journal-amount-includes-vat.good.al`](normal-vat-journal-amount-includes-vat.good.al).

## Anti Pattern

In the demonstrated automatic Normal-VAT configuration, put a provably VAT-exclusive source amount into journal `Amount` while expecting posting to add tax. An amount assignment alone, unknown setup, or a suggestive variable name is insufficient. Do not report the correctly supplied gross amount or automatically rewrite tax calculations outside this scope.

See sample: [`normal-vat-journal-amount-includes-vat.bad.al`](normal-vat-journal-amount-includes-vat.bad.al).

## References

- [VAT posting setup combinations](https://learn.microsoft.com/en-us/dynamics365/business-central/finance-setup-vat#combine-vat-posting-groups-in-vat-posting-setups).
- [BCApps: journal amount validation](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Finance/GeneralLedger/Journal/GenJournalLine.Table.al).
- [BCApps: Normal VAT extraction during posting](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Finance/GeneralLedger/Posting/GenJnlPostLine.Codeunit.al).
- [BCApps: journal VAT amount regression cases](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/Tests/VAT/ERMVATOnGenJournalLine.Codeunit.al).
