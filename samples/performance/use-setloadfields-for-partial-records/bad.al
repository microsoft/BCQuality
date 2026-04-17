codeunit 50111 "Perf Sample SetLoadFields Bad"
{
    procedure ExportItemNumbers(var Item: Record Item)
    begin
        if Item.FindSet() then
            repeat
                Export(Item."No.", Item.Description);
            until Item.Next() = 0;
    end;

    local procedure Export(ItemNo: Code[20]; Description: Text[100])
    begin
    end;
}
