// Both fields guarded the same way, out of habit rather than analysis.
if SalesHeader.Get(SalesHeader."Document Type"::Order, DocumentNo) then
    VATRegNo := SalesHeader."VAT Registration No.";  // low blast radius - fine

// but the same pattern, unexamined, was also applied here:
if SalesHeader.Get(SalesHeader."Document Type"::Order, DocumentNo) then
    VATBusPostingGroup := SalesHeader."VAT Bus. Posting Group"
else
    VATBusPostingGroup := '';
    // High blast radius: silently wrong VAT posting group reaches posting
    // with no error, no TestField, and no reviewer in the loop.
