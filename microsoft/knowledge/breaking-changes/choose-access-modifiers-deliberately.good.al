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

    /// <summary>
    /// Opens the order card so other extensions can reuse this entry point
    /// instead of duplicating the lookup logic.
    /// </summary>
    /// <param name="OrderNo">Specifies the order number to open.</param>
    // Deliberately widened from internal to public: the added XML doc comment
    // documents it for external callers, signaling intentional promotion, not
    // an accidental "public by default" widening.
    procedure OpenOrder(OrderNo: Code[20])
    begin
    end;
}
