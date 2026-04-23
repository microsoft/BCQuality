codeunit 51114 "Style Sample ErrorParams Good"
{
    procedure Fail(CustomerNo: Code[20]; DocumentNo: Code[20])
    var
        CustomerNotFoundErr: Label 'Customer %1 does not exist for document %2.',
            Comment = '%1 = Customer No., %2 = Document No.';
    begin
        // Label + arguments passed directly. Translations apply; telemetry classifies per field.
        Error(CustomerNotFoundErr, CustomerNo, DocumentNo);
    end;
}
