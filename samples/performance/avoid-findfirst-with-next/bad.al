codeunit 50105 "Perf Sample AvoidFindFirstNext Bad"
{
    procedure EmitAllItems(var Item: Record Item)
    begin
        if Item.FindFirst() then
            repeat
                EmitItem(Item);
            until Item.Next() = 0;
    end;

    local procedure EmitItem(var Item: Record Item)
    begin
    end;
}
