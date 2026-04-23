codeunit 51101 "Style Sample LabelSuffix Bad"
{
    procedure Example()
    var
        CannotDeleteLine: Label 'Cannot delete this line.';
        Text000: Label 'Update complete';
        UpdateLocation: Label 'Update location?';
        WrongSuffixTok: Label 'Customer %1 not found.', Comment = '%1 = Customer No.';
        CustomerNo: Code[20];
    begin
        Error(CannotDeleteLine);
        Message(Text000);
        if Confirm(UpdateLocation) then
            ;
        Error(WrongSuffixTok, CustomerNo);
    end;
}
