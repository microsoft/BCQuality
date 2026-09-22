table 50101 "Sample Order Line"
{
    fields
    {
        field(1; "Document No."; Code[20]) { }
        field(2; "Line No."; Integer) { }
        field(10; Quantity; Decimal) { }
        field(11; "Unit Price"; Decimal) { }
        field(12; "Line Amount"; Decimal) { }
    }
    keys
    {
        key(PK; "Document No.", "Line No.") { Clustered = true; }
    }
}

page 50100 "Sample Order Line Card"
{
    PageType = Card;
    SourceTable = "Sample Order Line";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(quantity; Rec.Quantity) { }
                field(unitPrice; Rec."Unit Price") { }
                field(lineAmount; Rec."Line Amount") { }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Recalculate)
            {
                trigger OnAction()
                begin
                    Rec."Line Amount" := Rec.Quantity * Rec."Unit Price";
                    Rec.Modify();
                end;
            }
        }
    }
}
