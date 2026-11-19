table 50364 "Sample Employee Good"
{
    Caption = 'Employee';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
        }
        field(3; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
        }
        field(4; "Annual Salary"; Decimal)
        {
            Caption = 'Annual Salary';
        }
    }

    keys
    {
        key(PK; "No.") { Clustered = true; }
    }
}

page 50364 "Sample Employee Directory Good"
{
    Caption = 'Employee Directory';
    PageType = List;
    SourceTable = "Sample Employee Good";
    UsageCategory = Lists;
    ApplicationArea = All;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Employees)
            {
                // The page every employee opens does not show the salary at all.
                field("No."; Rec."No.") { }
                field(Name; Rec.Name) { }
                field("Phone No."; Rec."Phone No.") { }
            }
        }
    }
}

page 50366 "Sample Employee Pay Card Good"
{
    Caption = 'Employee Pay Card';
    PageType = Card;
    SourceTable = "Sample Employee Good";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(Pay)
            {
                Caption = 'Pay';

                field("No."; Rec."No.") { }
                field(Name; Rec.Name) { }
                // Masked on screen against shoulder-surfing; who may open this page is
                // decided by permissions, not by the mask.
                field("Annual Salary"; Rec."Annual Salary")
                {
                    MaskType = Concealed;
                }
            }
        }
    }
}
