codeunit 50100 "Customer Credit Report"
{
    procedure ReportCreditLimits(StartNo: Code[20]; EndNo: Code[20])
    var
        Customer: Record Customer;
    begin
        // Filters applied first.
        Customer.SetRange("No.", StartNo, EndNo);
        Customer.SetRange(Blocked, Customer.Blocked::" ");

        // SetLoadFields is too late - the platform has already planned the
        // query for the full record. The call is paid for without delivering
        // any of the optimization benefit.
        Customer.SetLoadFields("No.", Name, "Credit Limit (LCY)");

        if Customer.FindSet() then
            repeat
                EmitLine(Customer."No.", Customer.Name, Customer."Credit Limit (LCY)");
            until Customer.Next() = 0;
    end;

    local procedure EmitLine(CustNo: Code[20]; Name: Text; CreditLimit: Decimal)
    begin
    end;
}
