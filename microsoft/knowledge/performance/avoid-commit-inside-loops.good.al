codeunit 50128 "Perf Sample CommitInLoop Good"
{
    procedure NormalizeCustomerNames()
    var
        Customer: Record Customer;
        RowsInChunk: Integer;
        ChunkSize: Integer;
    begin
        ChunkSize := 500;
        if Customer.FindSet(true) then
            repeat
                Customer.Name := UpperCase(Customer.Name);
                Customer.Modify();
                RowsInChunk += 1;
                if RowsInChunk >= ChunkSize then begin
                    Commit();
                    RowsInChunk := 0;
                end;
            until Customer.Next() = 0;
    end;
}
