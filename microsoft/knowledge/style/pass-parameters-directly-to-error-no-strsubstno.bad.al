codeunit 51115 "Style Sample ErrorParams Bad"
{
    procedure Fail(CustomerNo: Code[20])
    var
        CustomerNotFoundErr: Label 'Customer %1 does not exist.', Comment = '%1 = Customer No.';
    begin
        // Pre-built Text to Error: translation skipped, telemetry opaque.
        Error(StrSubstNo(CustomerNotFoundErr, CustomerNo));

        // Concatenation: translation skipped, hard-coded delimiters baked in.
        Error('Customer ' + CustomerNo + ' not found');
    end;
}
