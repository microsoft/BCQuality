query 50127 "Perf Customer Chunk"
{
    QueryType = Normal;
    OrderBy = ascending(CustomerNo);

    elements
    {
        dataitem(Customer; Customer)
        {
            column(CustomerNo; "No.") { }
        }
    }
}

codeunit 50128 "Perf Sample CommitInLoop Good"
{
    procedure NormalizeCustomerNames()
    var
        LastCustomerNo: Code[20];
    begin
        // The outer loop owns checkpoints; the per-row loop contains no Commit.
        while NormalizeNextChunk(LastCustomerNo) do
            Commit();
    end;

    local procedure NormalizeNextChunk(var LastCustomerNo: Code[20]): Boolean
    var
        Customer: Record Customer;
        TempCustomer: Record Customer temporary;
        CustomerChunk: Query "Perf Customer Chunk";
        LastChunkCustomerNo: Code[20];
    begin
        CustomerChunk.TopNumberOfRows(500);
        if LastCustomerNo <> '' then
            CustomerChunk.SetFilter(CustomerNo, '>%1', LastCustomerNo);
        CustomerChunk.Open();
        while CustomerChunk.Read() do begin
            TempCustomer.Init();
            TempCustomer."No." := CustomerChunk.CustomerNo;
            TempCustomer.Insert();
            LastChunkCustomerNo := CustomerChunk.CustomerNo;
        end;
        CustomerChunk.Close();

        if TempCustomer.IsEmpty() then
            exit(false);

        Customer.LockTable();
        if TempCustomer.FindSet() then
            repeat
                if Customer.Get(TempCustomer."No.") then begin
                    Customer.Name := UpperCase(Customer.Name);
                    Customer.Modify();
                end;
            until TempCustomer.Next() = 0;

        LastCustomerNo := LastChunkCustomerNo;
        exit(true);
    end;
}
