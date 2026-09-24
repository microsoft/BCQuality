enumextension 50100 "Sample Price Source Ext" extends "Price Source Type"
{
    value(50100; "Sample.LoyaltyTier")
    {
        Caption = 'Loyalty Tier';
        Implementation = "Price Source" = "Price Source - Customer", "Price Source Group" = "Price Source Group - Customer";
    }
}

enumextension 50101 "Sample Sales Price Source Ext" extends "Sales Price Source Type"
{
    // Same numeric ID (50100) as the Price Source Type value above. That
    // match is what makes "Sample.LoyaltyTier" show up as a selectable
    // Applies-to Type on an actual sales price list.
    value(50100; "Sample.LoyaltyTier")
    {
        Caption = 'Loyalty Tier';
    }
}
