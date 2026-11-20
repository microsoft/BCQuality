codeunit 50362 "Sample Customer Export Good"
{
    procedure ExportForSalesperson(SalespersonCode: Code[20]; var TargetStream: OutStream)
    var
        Customer: Record Customer;
    begin
        Customer.SetRange("Salesperson Code", SalespersonCode);

        // The filtered record is passed, so the XMLport exports only these customers.
        Xmlport.Export(Xmlport::"Sample Customer Export", TargetStream, Customer);
    end;
}
