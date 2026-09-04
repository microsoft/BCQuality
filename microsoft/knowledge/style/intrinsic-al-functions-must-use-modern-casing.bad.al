codeunit 50100 "Sales Task Notify"
{
    procedure NotifyUpdate(Count: Integer; CustomerNo: Code[20])
    begin
        MESSAGE('%1 records updated.', Count);

        IF NOT CONFIRM('Delete %1?', FALSE, CustomerNo) THEN
            EXIT;

        ERROR(STRSUBSTNO('%1 must not be blank.', CustomerNo));
    end;
}
