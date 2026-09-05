codeunit 50140 "Sample Confirm Usage"
{
    procedure ConfirmDeletion(RecordCount: Integer): Boolean
    var
        ConfirmMsg: Label 'Do you want to delete %1 records?';
    begin
        exit(Confirm(ConfirmMsg, false, RecordCount));
    end;
}
