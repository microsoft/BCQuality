codeunit 51119 "Style Sample Parentheses Bad"
{
    procedure Example(var Customer: Record Customer)
    var
        TempBuffer: Record "Integer" temporary;
    begin
        // Parentheses omitted. The call site reads like a field access.
        Customer.Init;
        TempBuffer.DeleteAll;
        if Customer.FindFirst then
            ;
    end;
}
