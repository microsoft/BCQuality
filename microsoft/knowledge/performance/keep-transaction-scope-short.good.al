codeunit 50123 "Perf Sample TxnScope Good"
{
    procedure ImportCustomers(var Source: List of [Text])
    var
        Prepared: Record Customer temporary;
        Customer: Record Customer;
    begin
        // read, validate, and shape outside the transaction
        PrepareRows(Source, Prepared);

        // transaction starts here: only Insert/Modify calls
        if Prepared.FindSet() then
            repeat
                Customer := Prepared;
                Customer.Insert(true);
            until Prepared.Next() = 0;
    end;

    local procedure PrepareRows(var Source: List of [Text]; var Prepared: Record Customer temporary)
    begin
    end;
}
