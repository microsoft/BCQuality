// The only supported read filters customer/date and displays item, quantity, and amount.
// No consumer needs ordering on the displayed fields or a SIFT aggregate.
table 50362 "Perf Document Entry"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer) { }
        field(2; "Customer No."; Code[20]) { }
        field(3; "Posting Date"; Date) { }
        field(4; "Item No."; Code[20]) { }
        field(5; Quantity; Decimal) { }
        field(6; Amount; Decimal) { }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(CustomerDatePayload; "Customer No.", "Posting Date")
        {
            IncludedFields = "Item No.", Quantity, Amount;
        }
    }
}

codeunit 50375 "Perf Document Reader Good"
{
    procedure CustomerDateTotals(CustomerNo: Code[20]; FromDate: Date; ToDate: Date; var ItemNos: List of [Code[20]]; var TotalAmount: Decimal; var TotalQuantity: Decimal)
    var
        Entry: Record "Perf Document Entry";
    begin
        Entry.SetRange("Customer No.", CustomerNo);
        Entry.SetRange("Posting Date", FromDate, ToDate);
        Entry.SetLoadFields("Item No.", Quantity, Amount);
        if Entry.FindSet() then
            repeat
                ItemNos.Add(Entry."Item No.");
                TotalQuantity += Entry.Quantity;
                TotalAmount += Entry.Amount;
            until Entry.Next() = 0;
    end;
}
