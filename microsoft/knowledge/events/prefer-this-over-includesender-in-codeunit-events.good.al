// Demonstration-only AL. Not compiled by CI; illustrates the article.
codeunit 50280 "Sender This Good Sample"
{
    procedure ProcessOrder(OrderNo: Code[20])
    begin
        // Pass the current instance explicitly as a typed Sender parameter.
        OnBeforeProcessOrder(OrderNo, this);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessOrder(OrderNo: Code[20]; Sender: Codeunit "Sender This Good Sample")
    begin
    end;
}
