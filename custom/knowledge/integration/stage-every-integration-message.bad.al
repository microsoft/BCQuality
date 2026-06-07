// Anti-pattern: the inbound API insert trigger enriches and posts inline.
// The HTTP request now holds posting locks and depends on two remote systems
// (the pricing service and the caller) staying responsive. A slow pricing call
// or a posting error surfaces to the caller as a request timeout, and the whole
// transaction rolls back: the message is lost, with no staged row to retry.

page 50100 "Sales Order Intake API"
{
    PageType = API;
    APIPublisher = 'contoso';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'salesOrderIntake';
    EntitySetName = 'salesOrderIntakes';
    SourceTable = "Sales Header";
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(externalNo; Rec."External Document No.") { }
                field(sellToCustomerNo; Rec."Sell-to Customer No.") { }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        SalesPost: Codeunit "Sales-Post";
        PricingClient: Codeunit "External Pricing Client";
    begin
        // BAD: a second remote call, inside the request that is creating the row.
        // If the pricing service is slow, the caller's HTTP request blocks on it.
        Rec.Validate("Unit Price", PricingClient.GetPrice(Rec."No."));

        // BAD: posting inline, inside the request transaction. Posting locks are
        // held for the whole HTTP round trip. A posting error rolls back the
        // insert too, so there is nothing left to inspect or retry.
        SalesPost.Run(Rec);

        // There is no staging row. A duplicate delivery (the source retried after
        // a timeout) is processed again from scratch, creating a second order.
    end;
}
