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
        CustomerChunk: Query "Perf Customer Chunk";
        FirstCustomerNo: Code[20];
        LastChunkCustomerNo: Code[20];
    begin
        CustomerChunk.TopNumberOfRows(500);
        if LastCustomerNo <> '' then
            CustomerChunk.SetFilter(CustomerNo, '>%1', LastCustomerNo);
        CustomerChunk.Open();
        if not CustomerChunk.Read() then begin
            CustomerChunk.Close();
            exit(false);
        end;

        FirstCustomerNo := CustomerChunk.CustomerNo;
        repeat
            LastChunkCustomerNo := CustomerChunk.CustomerNo;
        until not CustomerChunk.Read();
        CustomerChunk.Close();

        Customer.SetCurrentKey("No.");
        Customer.SetRange("No.", FirstCustomerNo, LastChunkCustomerNo);
        if not Customer.FindSet(true) then begin
            LastCustomerNo := LastChunkCustomerNo;
            exit(true);
        end;

        repeat
            Customer.Name := UpperCase(Customer.Name);
            Customer.Modify();
        until Customer.Next() = 0;

        LastCustomerNo := LastChunkCustomerNo;
        exit(true);
    end;
}
