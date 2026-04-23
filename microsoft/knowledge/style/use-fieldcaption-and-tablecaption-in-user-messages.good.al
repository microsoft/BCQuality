codeunit 51110 "Style Sample FieldCaption Good"
{
    procedure Example(var SalesLine: Record "Sales Line")
    var
        UpdateLocationQst: Label 'Update the %1?', Comment = '%1 = field caption';
        TableUpdatedMsg: Label 'Updated %1.', Comment = '%1 = table caption';
    begin
        // Captions are localized for the current user's language.
        if not Confirm(UpdateLocationQst, true, SalesLine.FieldCaption("Location Code")) then
            exit;
        Message(TableUpdatedMsg, SalesLine.TableCaption());
    end;
}
