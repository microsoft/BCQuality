// Low blast radius: guard, with an explicit chosen fallback.
if Customer.Get(SalesHeader."Sell-to Customer No.") then
    CustomerHomePage := Customer."Home Page"
else
    CustomerHomePage := '';
// Blank is an acceptable, deliberately-considered default here - the field
// is purely a display convenience and a reviewer sees it before the document ships.
// It is assigned explicitly, though, not left to whatever the variable
// happened to hold before this lookup ran.

// High blast radius: let it fail loud, because this feeds posted VAT.
SalesHeader.Get(SalesHeader."Document Type"::Order, DocumentNo);
SalesHeader.TestField("VAT Bus. Posting Group");
VATBusPostingGroup := SalesHeader."VAT Bus. Posting Group";
