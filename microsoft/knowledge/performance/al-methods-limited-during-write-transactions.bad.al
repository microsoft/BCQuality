codeunit 50258 "Perf Sample RunModalInTxn Bad"
{
    procedure ChangeShippingAgent(DocNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
        ShippingAgent: Record "Shipping Agent";
    begin
        SalesHeader.Get(SalesHeader."Document Type"::Order, DocNo);
        SalesHeader."Shipment Date" := WorkDate();
        SalesHeader.Modify(true); // a write transaction is now open

        // Runtime error: RunModal is not allowed in write transactions.
        if Page.RunModal(Page::"Shipping Agents", ShippingAgent) = Action::LookupOK then begin
            SalesHeader.Validate("Shipping Agent Code", ShippingAgent.Code);
            SalesHeader.Modify(true);
        end;
    end;
}
