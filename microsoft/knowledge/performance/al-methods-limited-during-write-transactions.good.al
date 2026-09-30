codeunit 50259 "Perf Sample RunModalInTxn Good"
{
    procedure ChangeShippingAgent(DocNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
        ShippingAgent: Record "Shipping Agent";
    begin
        // User interaction first, while no write transaction is open.
        if Page.RunModal(Page::"Shipping Agents", ShippingAgent) <> Action::LookupOK then
            exit;

        // All writes after the choice is made; the transaction ends with the trigger.
        SalesHeader.Get(SalesHeader."Document Type"::Order, DocNo);
        SalesHeader."Shipment Date" := WorkDate();
        SalesHeader.Validate("Shipping Agent Code", ShippingAgent.Code);
        SalesHeader.Modify(true);
    end;
}
