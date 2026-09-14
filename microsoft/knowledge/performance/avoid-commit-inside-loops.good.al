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
    procedure IncreaseCustomerCreditLimits()
    var
        CreditLimitState: Record "Perf Credit Limit State";
        LastCustomerNo: Code[20];
    begin
        if not CreditLimitState.Get('CUSTOMER') then begin
            CreditLimitState.Init();
            CreditLimitState.Code := 'CUSTOMER';
            CreditLimitState.Insert();
        end;
        LastCustomerNo := CreditLimitState."Last Customer No.";

        while IncreaseNextChunk(LastCustomerNo) do begin
            CreditLimitState."Last Customer No." := LastCustomerNo;
            CreditLimitState.Modify();
            Commit();
        end;
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

table 50128 "Perf Credit Limit State"
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
