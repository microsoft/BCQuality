codeunit 50187 "Collect Errors Bad Sample"
{
    procedure ValidateAllItems()
    var
        Item: Record Item;
        ErrorText: Text;
    begin
        // Hand-rolled accumulation: reimplements the platform feature, loses each
        // error's ErrorInfo structure, and skips telemetry classification.
        if Item.FindSet() then
            repeat
                if Item.Description = '' then
                    ErrorText += StrSubstNo('Item %1 has no description.\', Item."No.");
                if Item."Unit Cost" <= 0 then
                    ErrorText += StrSubstNo('Item %1 must have a positive unit cost.\', Item."No.");
            until Item.Next() = 0;

        if ErrorText <> '' then
            Error(ErrorText);
    end;
}
