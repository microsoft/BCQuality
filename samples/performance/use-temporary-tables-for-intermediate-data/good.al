codeunit 50124 "Perf Sample TempTable Good"
{
    procedure BuildAffectedItems(var TempItem: Record Item temporary)
    var
        SalesLine: Record "Sales Line";
    begin
        TempItem.Reset();
        TempItem.DeleteAll();
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        if SalesLine.FindSet() then
            repeat
                TempItem."No." := SalesLine."No.";
                if TempItem.Insert(false) then;
            until SalesLine.Next() = 0;
    end;
}
