codeunit 50100 "Customer Temp Processor"
{
    procedure BuildScopedCustomerBuffer(CustomerNoFilter: Text): Boolean
    var
        Customer: Record Customer;
        TempCustomer: Record Customer temporary;
    begin
        // Validate the caller's permission before copying sensitive rows.
        if not Customer.ReadPermission() then
            exit(false);

        Customer.SetFilter("No.", CustomerNoFilter);
        if not Customer.FindSet() then
            exit(true);

        repeat
            TempCustomer := Customer;
            TempCustomer.Insert();
        until Customer.Next() = 0;

        ProcessCustomerBuffer(TempCustomer);

        // Explicit cleanup on the normal exit path.
        TempCustomer.DeleteAll();
        exit(true);
    end;

    local procedure ProcessCustomerBuffer(var TempCustomer: Record Customer temporary)
    begin
        // Use the buffer in-place; do not persist values elsewhere.
    end;
}
