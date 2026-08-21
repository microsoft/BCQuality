table 50100 "Campaign Member"
{
    Caption = 'Campaign Member';
    LookupPageId = Page::"Campaign Member Lookup";
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

page 50100 "Campaign Member Lookup"
{
    PageType = List;
    SourceTable = "Campaign Member";
    Caption = 'Campaign Members';

    layout
    {
        area(content)
        {
            repeater(Rows)
            {
                field("No."; Rec."No.") { }
                field(Name; Rec.Name) { }
            }
        }
    }
}

page 50101 "Campaign Member List"
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
    }
}
