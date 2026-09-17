codeunit 50100 "HttpClient Holds Locks Good"
{
    procedure SyncCustomerLastName(var Customer: Record Customer)
    var
        CustomerSyncOutbox: Record "Customer Sync Outbox";
    begin
        Customer."Search Name" := Customer.Name;
        Customer.Modify(false);

        // This work item commits or rolls back with the customer change.
        CustomerSyncOutbox."Customer No." := Customer."No.";
        CustomerSyncOutbox.Insert();
    end;
}

table 50100 "Customer Sync Outbox"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Customer No."; Code[20]) { }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}

codeunit 50101 "Customer Sync Outbox Worker"
{
    // Configure this codeunit as a recurring job queue entry.
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        Customer: Record Customer;
        CustomerSyncOutbox: Record "Customer Sync Outbox";
        Client: HttpClient;
        Response: HttpResponseMessage;
    begin
        // Only committed work is visible here; a rolled-back change leaves no outbox row.
        if not CustomerSyncOutbox.FindFirst() then
            exit;

        Customer.Get(CustomerSyncOutbox."Customer No.");
        Client.Get(StrSubstNo('https://example.local/sync/%1', Customer."No."), Response);
        if not Response.IsSuccessStatusCode() then
            Error('Customer sync failed with HTTP status %1.', Response.HttpStatusCode());

        // Delete only after HTTP completes, so no write lock is held during the call.
        CustomerSyncOutbox.Delete();
    end;
}
