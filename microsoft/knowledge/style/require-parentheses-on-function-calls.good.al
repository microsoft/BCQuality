codeunit 51118 "Style Sample Parentheses Good"
{
    procedure Example(var Customer: Record Customer)
    var
        TempBuffer: Record "Integer" temporary;
    begin
        Customer.Init();
        TempBuffer.DeleteAll();
        if Customer.FindFirst() then
            ;
    end;
}
