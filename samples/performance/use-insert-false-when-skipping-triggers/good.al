codeunit 50132 "Perf Sample InsertParam Good"
{
    procedure BulkLoadTempItems(var TempItem: Record Item temporary; Source: List of [Code[20]])
    var
        ItemNo: Code[20];
    begin
        foreach ItemNo in Source do begin
            TempItem."No." := ItemNo;
            TempItem.Insert(false);
        end;
    end;
}
