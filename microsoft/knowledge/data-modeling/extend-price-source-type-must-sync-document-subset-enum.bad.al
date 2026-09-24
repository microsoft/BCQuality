enumextension 50100 "Sample Price Source Ext" extends "Price Source Type"
{
    value(50100; "Sample.LoyaltyTier")
    {
        Caption = 'Loyalty Tier';
        Implementation = "Price Source" = "Price Source - Customer", "Price Source Group" = "Price Source Group - Customer";
    }
}

// WRONG: no matching value was added to "Sales Price Source Type" (or the
// purchase/job equivalents). "Sample.LoyaltyTier" compiles, installs, and
// is a real value on "Price Source Type" - it just never appears as an
// Applies-to Type option on the Sales Price List page, because that page
// is driven by the separate subset enum, not the base one.
