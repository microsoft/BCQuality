codeunit 50100 "Sales Task Notify"
{
    procedure NotifyUpdate(Count: Integer; CustomerNo: Code[20])
    begin
        Message('%1 records updated.', Count);

        if not Confirm('Delete %1?', false, CustomerNo) then
            exit;

        Error(StrSubstNo('%1 must not be blank.', CustomerNo));
    end;
}
