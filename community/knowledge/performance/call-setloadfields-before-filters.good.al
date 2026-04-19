codeunit 50100 "Customer Credit Report"
{
    procedure ReportCreditLimits(StartNo: Code[20]; EndNo: Code[20])
    var
        Customer: Record Customer;
    begin
        // 1. Declare the minimal load first, before any filter.
        Customer.SetLoadFields("No.", Name, "Credit Limit (LCY)");

        // 2. Apply filters.
        Customer.SetRange("No.", StartNo, EndNo);
        Customer.SetRange(Blocked, Customer.Blocked::" ");

        // 3. Iterate; the query loads only the three declared fields.
        if Customer.FindSet() then
            repeat
                EmitLine(Customer."No.", Customer.Name, Customer."Credit Limit (LCY)");
            until Customer.Next() = 0;
    end;

    local procedure EmitLine(CustNo: Code[20]; Name: Text; CreditLimit: Decimal)
    begin
    end;
}
