// Demonstration only. Shows the recommended pattern: the restricting filter is placed in a hidden filter group.

page 50185 "My Expense Claims Good"
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
        // Group 2 is not editable from the filter pane; the user can only narrow within it.
        // Confidentiality of other employees' claims is enforced separately by security filters.
        Rec.FilterGroup(2);
        Rec.SetRange("Employee User ID", UserId());
        Rec.FilterGroup(0);
    end;
}

table 50185 "Expense Claim Demo"
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
