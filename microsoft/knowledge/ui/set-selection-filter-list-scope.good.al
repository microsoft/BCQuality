// Good: check MarkedOnly before deciding which scope to process.
// When MarkedOnly is false (cursor-only or Ctrl+A) fall back to Copy(Rec)
// so every record visible in the page view is included.
trigger OnAction()
var
    PriceListHeader: Record "Price List Header";
    TempErrorMessage: Record "Error Message" temporary;
    ProcessingCodeunit: Codeunit "My Batch Processor";
begin
    CurrPage.SetSelectionFilter(PriceListHeader);
    if not PriceListHeader.MarkedOnly then
        PriceListHeader.Copy(Rec);
    ProcessingCodeunit.RunBatch(PriceListHeader, TempErrorMessage);
end;
