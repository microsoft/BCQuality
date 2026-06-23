// Demonstration-only AL. Not compiled by CI; illustrates the article.
codeunit 50281 "Sender This Bad Sample"
{
    procedure ProcessOrder(OrderNo: Code[20])
    begin
        OnBeforeProcessOrder(OrderNo);
    end;

    // Anti-pattern: IncludeSender = true is used only to expose the publisher
    // instance to subscribers; a codeunit can pass 'this' explicitly instead.
    [IntegrationEvent(true, false)]
    local procedure OnBeforeProcessOrder(OrderNo: Code[20])
    begin
    end;
}
