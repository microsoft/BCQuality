table 50360 "Perf Read Entry"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer) { }
        field(2; "Customer No."; Code[20]) { }
        field(3; "Posting Date"; Date) { }
        field(4; "Item No."; Code[20]) { }
        field(5; Quantity; Decimal) { }
        field(6; Description; Text[100]) { }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(ByDescription; Description, "Item No.", "Posting Date") { }
        key(ByQuantity; Quantity, "Customer No.") { }
    }
}

codeunit 50361 "Perf Read Entry Bad"
{
    procedure SumNonblankItems(CustomerNo: Code[20]; FromDate: Date; ToDate: Date) Total: Decimal
    var
        Entry: Record "Perf Read Entry";
    begin
        Entry.SetRange("Customer No.", CustomerNo);
        Entry.SetRange("Posting Date", FromDate, ToDate);
        Entry.SetLoadFields("Item No.", Quantity);
        if Entry.FindSet() then
            repeat
                if Entry."Item No." <> '' then
                    Total += Entry.Quantity;
            until Entry.Next() = 0;
    end;
}
