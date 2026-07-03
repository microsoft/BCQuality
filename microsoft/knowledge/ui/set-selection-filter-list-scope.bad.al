// Bad: SetSelectionFilter with cursor-only (no explicit multi-selection) produces
// a primary key filter for just that one row. The codeunit receives only that row;
// the rest of the visible list is silently skipped with no error raised.
trigger OnAction()
var
    PriceListHeader: Record "Price List Header";
    TempErrorMessage: Record "Error Message" temporary;
    ProcessingCodeunit: Codeunit "My Batch Processor";
begin
    CurrPage.SetSelectionFilter(PriceListHeader);
    ProcessingCodeunit.RunBatch(PriceListHeader, TempErrorMessage);
end;
