codeunit 50900 "Privacy Sample StrSubstNo Good"
{
    procedure FailCustomer(var Customer: Record Customer)
    var
        CustomerDataInvalidErr: Label 'Customer %1 has invalid data.', Comment = '%1 = Customer No.';
    begin
        // Platform sees the Label and the field reference. It inspects the
        // field's DataClassification and handles telemetry correctly.
        Error(CustomerDataInvalidErr, Customer."No.");
    end;
}
