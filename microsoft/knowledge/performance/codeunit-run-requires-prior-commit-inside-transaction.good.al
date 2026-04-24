codeunit 50145 "Perf Sample DeferredLog Good"
{
    procedure ApplyDiscountToSelection(var Customer: Record Customer)
    var
        ApplyOne: Codeunit "Perf Sample DeferredLog Apply";
        FailedCustomerNos: List of [Code[20]];
        FailureReasons: List of [Text];
        Index: Integer;
    begin
        if Customer.FindSet() then
            repeat
                ClearLastError();
                if not ApplyOne.Run(Customer) then begin
                    FailedCustomerNos.Add(Customer."No.");
                    FailureReasons.Add(GetLastErrorText());
                end;
            until Customer.Next() = 0;

        for Index := 1 to FailedCustomerNos.Count() do
            WriteFailureLog(FailedCustomerNos.Get(Index), FailureReasons.Get(Index));
    end;

    local procedure WriteFailureLog(CustomerNo: Code[20]; Reason: Text)
    begin
    end;
}

codeunit 50146 "Perf Sample DeferredLog Apply"
{
    TableNo = Customer;

    trigger OnRun()
    begin
        Rec.Validate("Customer Price Group", 'VIP');
        Rec.Modify(true);
    end;
}
