codeunit 50325 "Order Processor Good"
{
    // Supported, stable entry point — intentionally public.
    procedure ProcessOrder(OrderNo: Code[20])
    begin
        ValidateOrder(OrderNo);
        PostOrder(OrderNo);
    end;

    // In-app reuse only — internal, so it is not part of the external contract.
    internal procedure ValidateOrder(OrderNo: Code[20])
    begin
        if OrderNo = '' then
            Error('Order number is required.');
    end;

    // Implementation detail confined to this object — local.
    local procedure PostOrder(OrderNo: Code[20])
    begin
    end;
}

codeunit 50327 "Order Validation Service"
{
    Access = Internal;

    procedure HasOrderNumber(OrderNo: Code[20]): Boolean
    begin
        exit(OrderNo <> '');
    end;
}

codeunit 50328 "Order Validation Caller"
{
    Access = Internal;

    procedure CanProcess(OrderNo: Code[20]): Boolean
    var
        Validator: Codeunit "Order Validation Service";
    begin
        exit(Validator.HasOrderNumber(OrderNo));
    end;
}
