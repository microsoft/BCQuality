codeunit 50110 "Perf Sample SetLoadFields Good"
{
    procedure ExportItemNumbers(var Item: Record Item)
    begin
        Item.SetLoadFields("No.", Description);
        if Item.FindSet() then
            repeat
                Export(Item."No.", Item.Description);
            until Item.Next() = 0;
    end;

    local procedure Export(ItemNo: Code[20]; Description: Text[100])
    begin
    end;
}
