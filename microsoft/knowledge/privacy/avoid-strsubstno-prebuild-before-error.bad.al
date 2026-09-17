codeunit 50207 "Privacy Sample StrSubstNo Bad"
{
    procedure ReportFailure(var Customer: Record Customer)
    var
        CustomerInvalidErr: Label 'Customer %1 has invalid data.', Comment = '%1 = Customer No.';
    begin
        Error(StrSubstNo(CustomerInvalidErr, Customer."No."));
    end;

    procedure ReportCombinedFailure()
    var
        HeaderErr: Label 'Customer validation failed. ';
        DetailErr: Label 'Correct the customer card and try again.';
    begin
        Error(HeaderErr + DetailErr);
    end;
}
