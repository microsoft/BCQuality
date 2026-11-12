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
        AlreadyMatched: Decimal;
        QtyToMatch: Decimal;
    begin
        // Sum what other documents already reserved on this order line.
        SampleMatch.SetRange("Order No.", OrderNo);
        SampleMatch.SetRange("Order Line No.", OrderLineNo);
        if SampleMatch.FindSet() then
            repeat
                AlreadyMatched += SampleMatch."Matched Qty.";
            until SampleMatch.Next() = 0;

        QtyToMatch := LineQty - AlreadyMatched;
        if QtyToMatch > RequestedQty then
            QtyToMatch := RequestedQty;
        if QtyToMatch <= 0 then
            exit;

        // Same variable: Init() keeps "Entry No." from the last row the loop
        // read, so once any match exists this Insert fails instead of getting a new number.
        SampleMatch.Init();
        SampleMatch."Order No." := OrderNo;
        SampleMatch."Order Line No." := OrderLineNo;
        SampleMatch."Matched Qty." := QtyToMatch;
        SampleMatch.Insert(true);
    end;
}
