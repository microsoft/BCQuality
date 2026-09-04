// Low blast radius: guard, with an explicit chosen fallback.
if SalesHeader.Get(SalesHeader."Document Type"::Order, DocumentNo) then
    VATRegNo := SalesHeader."VAT Registration No.";
// Blank is an acceptable, deliberately-considered default here - the field
// is informational and a reviewer sees it before the document ships.

// High blast radius: let it fail loud, because this feeds posted VAT.
SalesHeader.Get(SalesHeader."Document Type"::Order, DocumentNo);
SalesHeader.TestField("VAT Bus. Posting Group");
VATBusPostingGroup := SalesHeader."VAT Bus. Posting Group";
