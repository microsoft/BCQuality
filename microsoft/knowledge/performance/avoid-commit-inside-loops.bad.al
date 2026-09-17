codeunit 50129 "Perf Sample CommitInLoop Bad"
{
    procedure NormalizeCustomerNames()
    var
        Customer: Record Customer;
        LastCustomerNo: Code[20];
        ProcessedCount: Integer;
    begin
        Customer.SetFilter("No.", '>%1', LastCustomerNo);
        if Customer.FindSet(true) then
            repeat
                Customer.Name := UpperCase(Customer.Name);
                Customer.Modify();

                // LastCustomerNo exists only in memory, so a retry cannot exclude
                // work that was already committed.
                LastCustomerNo := Customer."No.";
                ProcessedCount += 1;

                // This still opened a FindSet over the complete remaining tail;
                // periodic commits do not turn retrieval into bounded TOP X.
                if ProcessedCount mod 500 = 0 then
                    Commit();
            until Customer.Next() = 0;
    end;
}
