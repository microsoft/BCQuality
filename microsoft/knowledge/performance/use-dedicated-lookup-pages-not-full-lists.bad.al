table 50100 "Campaign Member"
{
    Caption = 'Campaign Member';
    // Full list as lookup runs FactBoxes and extra columns on every dropdown.
    LookupPageId = Page::"Campaign Member List";
    DrillDownPageId = Page::"Campaign Member List";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20]) { }
        field(2; Name; Text[100]) { }
        field(3; "Balance (LCY)"; Decimal) { }
    }

    keys
    {
        key(PK; "No.") { Clustered = true; }
    }
}

page 50100 "Campaign Member List"
{
    PageType = List;
    SourceTable = "Campaign Member";

    layout
    {
        area(content)
        {
            repeater(Rows)
            {
                field("No."; Rec."No.") { }
                field(Name; Rec.Name) { }
                field("Balance (LCY)"; Rec."Balance (LCY)") { }
            }
        }
        area(factboxes)
        {
            // Full list carries this FactBox on every dropdown open — expensive.
            part(Details; "Campaign Member Details FB") { }
        }
    }
}

page 50101 "Campaign Member Details FB"
{
    PageType = CardPart;
    SourceTable = "Campaign Member";

    layout
    {
        area(content)
        {
            field("No."; Rec."No.") { }
            field(Name; Rec.Name) { }
            field("Balance (LCY)"; Rec."Balance (LCY)") { }
        }
    }
}
