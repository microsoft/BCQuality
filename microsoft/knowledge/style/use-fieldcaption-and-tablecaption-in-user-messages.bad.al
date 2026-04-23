codeunit 51111 "Style Sample FieldCaption Bad"
{
    procedure Example(var SalesLine: Record "Sales Line")
    var
        UpdateLocationQst: Label 'Update the %1?', Comment = '%1 = field';
    begin
        // FieldName/TableName return English identifiers. User with a non-English
        // locale sees the English "Location Code" inside an otherwise translated dialog.
        if not Confirm(UpdateLocationQst, true, SalesLine.FieldName("Location Code")) then
            exit;
    end;
}
