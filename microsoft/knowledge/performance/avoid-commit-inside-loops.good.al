codeunit 50128 "Perf Sample CommitInLoop Good"
{
    procedure NormalizeCustomerNames()
    var
        LastCustomerNo: Code[20];
    begin
        // The outer loop owns checkpoints; the per-row loop contains no Commit.
        while NormalizeNextChunk(LastCustomerNo, 500) do
            Commit();
    end;

    local procedure NormalizeNextChunk(var LastCustomerNo: Code[20]; ChunkSize: Integer): Boolean
    var
        Customer: Record Customer;
        RowsInChunk: Integer;
    begin
        Customer.SetCurrentKey("No.");
        if LastCustomerNo <> '' then
            Customer.SetFilter("No.", '>%1', LastCustomerNo);
        if not Customer.FindSet(true) then
            exit(false);

        repeat
            Customer.Name := UpperCase(Customer.Name);
            Customer.Modify();
            LastCustomerNo := Customer."No.";
            RowsInChunk += 1;
        until (RowsInChunk >= ChunkSize) or (Customer.Next() = 0);

        exit(true);
    end;
}
