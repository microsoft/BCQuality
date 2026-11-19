table 50365 "Sample Employee Bad"
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

page 50365 "Sample Employee Directory Bad"
{
    Caption = 'Employee Directory';
    PageType = List;
    SourceTable = "Sample Employee Bad";
    UsageCategory = Lists;
    ApplicationArea = All;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Employees)
            {
                field("No."; Rec."No.") { }
                field(Name; Rec.Name) { }
                field("Phone No."; Rec."Phone No.") { }
                // The directory is open to every employee; masking is relied on to keep
                // salaries private, and MaskType is not allowed in a repeater at all.
                field("Annual Salary"; Rec."Annual Salary")
                {
                    MaskType = Concealed;
                }
            }
        }
    }
}
