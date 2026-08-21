codeunit 50100 "HttpClient Holds Locks Good"
{
    // Write completes inside the caller's transaction; HTTP deferred so locks are released with it.
    procedure SyncCustomerLastName(var Customer: Record Customer)
    begin
        Customer."Search Name" := Customer.Name;
        Customer.Modify(false);
        // RecordId binds the task to this specific customer; the platform loads it into Rec on OnRun.
        TaskScheduler.CreateTask(Codeunit::"Customer Sync Task", 0, true, CompanyName(), CurrentDateTime(), Customer.RecordId);
    end;
}

codeunit 50101 "Customer Sync Task"
{
    TableNo = Customer;

    trigger OnRun()
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
    begin
        // Separate session: Rec is the single customer passed via RecordId; no write-transaction lock is held.
        Client.Get(StrSubstNo('https://example.local/sync/%1', Rec."No."), Response);
    end;
}
