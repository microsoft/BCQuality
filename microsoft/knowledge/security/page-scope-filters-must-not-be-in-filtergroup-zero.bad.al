// Demonstration only. Shows the wrong pattern: a page restricts its records with a filter the user can remove.

page 50184 "My Expense Claims Bad"
{
    PageType = List;
    SourceTable = "Expense Claim Demo";
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Claims)
            {
                field("No."; Rec."No.") { }
                field("Employee User ID"; Rec."Employee User ID") { }
                field(Amount; Rec.Amount) { }
            }

        }
    }

    trigger OnOpenPage()
    begin
        // BAD: no FilterGroup call, so this filter is in group 0. The user can clear it in the
        // filter pane and see every employee's claims.
        Rec.SetRange("Employee User ID", UserId());
    end;
}

table 50184 "Expense Claim Demo"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20]) { }
        field(2; "Employee User ID"; Text[50]) { }
        field(3; Amount; Decimal) { }
    }

    keys
    {
        key(PK; "No.") { Clustered = true; }
    }
}
