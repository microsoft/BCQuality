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

codeunit 50129 "Perf Sample CommitInLoop Bad"
{
    procedure IncreaseCustomerCreditLimits()
    var
        LastCustomerNo: Code[20];
    begin
        while IncreaseNextChunk(LastCustomerNo) do
            Commit();
    end;

    local procedure IncreaseNextChunk(var LastCustomerNo: Code[20]): Boolean
    var
        Customer: Record Customer;
        TempCustomer: Record Customer temporary;
        CustomerChunk: Query "Perf Customer Chunk";
        ChunkStartedAt: DateTime;
        MaxChunkDuration: Duration;
    begin
        ChunkStartedAt := CurrentDateTime();
        MaxChunkDuration := 60000;
        CustomerChunk.TopNumberOfRows(500);
        if LastCustomerNo <> '' then
            CustomerChunk.SetFilter(CustomerNo, '>%1', LastCustomerNo);
        CustomerChunk.Open();
        while CustomerChunk.Read() do begin
            TempCustomer.Init();
            TempCustomer."No." := CustomerChunk.CustomerNo;
            TempCustomer.Insert();
        end;
        CustomerChunk.Close();

        if TempCustomer.IsEmpty() then
            exit(false);

        Customer.LockTable();
        if TempCustomer.FindSet() then
            repeat
                if Customer.Get(TempCustomer."No.") then begin
                    Customer."Credit Limit (LCY)" += 100;
                    Customer.Modify();
                end;
                LastCustomerNo := TempCustomer."No.";
            until (TempCustomer.Next() = 0) or (CurrentDateTime() - ChunkStartedAt >= MaxChunkDuration);

        exit(true);
    end;
}
