---
bc-version: [all]
domain: upgrade
keywords: [upgrade-tag, nesting, complexity, upgrade-per-company, upgrade-per-database]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Upgrade tag conditional logic must not nest more than 2 levels deep

## Description

The conditional logic that gates upgrade code behind
[[use-upgrade-tags-not-version-checks]] should be at most two levels of
nesting: check the tag, exit if already applied, otherwise run the
upgrade step. Deeper nesting — tag checks inside tag checks, or tag
checks combined with multi-branch business-data conditions — signals
that the upgrade step is trying to do more than one thing, or that it's
reconstructing decision logic that belongs in the tag structure itself
(one tag per distinct upgrade step), not in nested `if`s inside a single
step.

Upgrade code runs unattended, once, against production data with no
chance to interactively debug a wrong branch — the cost of a nesting-driven
mistake here is much higher than in ordinary application code, which is
exactly why the ceiling is lower than general AL style would otherwise
allow.

## Best Practice

```al
local procedure UpgradeCustomerDiscountField()
begin
    if UpgradeTag.HasUpgradeTag(GetCustomerDiscountFieldTag()) then
        exit;

    Customer.SetLoadFields("Discount %");
    if Customer.FindSet() then
        repeat
            ...
        until Customer.Next() = 0;

    UpgradeTag.SetUpgradeTag(GetCustomerDiscountFieldTag());
end;
```

One tag check, one exit, one upgrade action — two levels deep at most.

## Anti Pattern

```al
local procedure UpgradeCustomerDiscountField()
begin
    if not UpgradeTag.HasUpgradeTag(GetCustomerDiscountFieldTag()) then begin
        if Customer.FindSet() then begin
            repeat
                if Customer."Discount %" = 0 then begin
                    if Customer."Customer Posting Group" <> '' then
                        Customer."Discount %" := 5;
                end;
            until Customer.Next() = 0;
        end;
        UpgradeTag.SetUpgradeTag(GetCustomerDiscountFieldTag());
    end;
end;
```

Four levels deep, and the business condition (posting group presence) is
buried inside the upgrade-tag guard instead of being its own clearly
named step — split this into separate, individually tagged upgrade
procedures instead.

## Source

alguidelines.dev, "AL Upgrade Instructions" (Microsoft-endorsed community
guidance), cross-checked against CURABIS's own knowledge base
(2026-08-13) — existing upgrade-domain rules cover trigger structure,
upgrade tags, and external-call restrictions, but not a nesting-depth
ceiling for the conditional logic itself; this fills that gap.
