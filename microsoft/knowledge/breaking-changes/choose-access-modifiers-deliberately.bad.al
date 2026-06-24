codeunit 50326 "Order Processor Bad"
{
    // Anti-pattern: every helper is public by default, exposing implementation
    // detail as a de-facto API. Each becomes a contract that cannot be changed
    // without risking breakage for consumers that bound to it.
    procedure ProcessOrder(OrderNo: Code[20])
    begin
        ValidateOrder(OrderNo);
        PostOrder(OrderNo);
    end;

    procedure ValidateOrder(OrderNo: Code[20])
    begin
        if OrderNo = '' then
            Error('Order number is required.');
    end;

    procedure PostOrder(OrderNo: Code[20])
    begin
    end;
}
