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
        NormalizeState: Record "Perf Normalize State";
        LastCustomerNo: Code[20];
    begin
        if not NormalizeState.Get('CUSTOMER') then begin
            NormalizeState.Init();
            NormalizeState.Code := 'CUSTOMER';
            NormalizeState.Insert();
        end;
        LastCustomerNo := NormalizeState."Last Customer No.";

        while NormalizeNextChunk(LastCustomerNo) do begin
            // Persist progress in the same transaction as the completed chunk.
            NormalizeState."Last Customer No." := LastCustomerNo;
            NormalizeState.Modify();
            Commit();
        end;
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

table 50128 "Perf Normalize State"
{
    fields
    {
        field(1; Code; Code[10]) { }
        field(2; "Last Customer No."; Code[20]) { }
    }

    keys
    {
        key(PK; Code) { Clustered = true; }
    }
}
