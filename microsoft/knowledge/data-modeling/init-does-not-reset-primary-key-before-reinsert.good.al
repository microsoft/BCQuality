table 50110 "Sample Order Match"
{
    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Order No."; Code[20])
        {
        }
        field(3; "Order Line No."; Integer)
        {
        }
        field(4; "Matched Qty."; Decimal)
        {
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}

codeunit 50111 "Sample Order Matcher"
{
    procedure MatchAgainstOrderLine(OrderNo: Code[20]; OrderLineNo: Integer; LineQty: Decimal; RequestedQty: Decimal)
    var
        SampleMatch: Record "Sample Order Match";
        ExistingMatch: Record "Sample Order Match";
        AlreadyMatched: Decimal;
        QtyToMatch: Decimal;
    begin
        // Sum what other documents already reserved on this order line -
        // with a separate variable, so the insert variable never holds a read key.
        ExistingMatch.SetRange("Order No.", OrderNo);
        ExistingMatch.SetRange("Order Line No.", OrderLineNo);
        if ExistingMatch.FindSet() then
            repeat
                AlreadyMatched += ExistingMatch."Matched Qty.";
            until ExistingMatch.Next() = 0;

        QtyToMatch := LineQty - AlreadyMatched;
        if QtyToMatch > RequestedQty then
            QtyToMatch := RequestedQty;
        if QtyToMatch <= 0 then
            exit;

        // SampleMatch has read nothing, so Init() starts from a blank
        // "Entry No." and the platform assigns the next number.
        SampleMatch.Init();
        SampleMatch."Order No." := OrderNo;
        SampleMatch."Order Line No." := OrderLineNo;
        SampleMatch."Matched Qty." := QtyToMatch;
        SampleMatch.Insert(true);
    end;
}
