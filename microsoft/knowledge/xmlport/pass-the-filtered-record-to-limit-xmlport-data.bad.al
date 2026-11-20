codeunit 50363 "Sample Customer Export Bad"
{
    procedure ExportForSalesperson(SalespersonCode: Code[20]; var TargetStream: OutStream)
    var
        Customer: Record Customer;
    begin
        Customer.SetRange("Salesperson Code", SalespersonCode);

        // The filtered record is not passed: the XMLport exports every customer.
        Xmlport.Export(Xmlport::"Sample Customer Export", TargetStream);
    end;
}
