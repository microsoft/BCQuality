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
    }

    keys
    {
        key(PK; "No.") { Clustered = true; }
    }
}

// Pay data lives in its own table so permissions can restrict it.
table 50366 "Sample Employee Pay Good"
{
    Caption = 'Employee Pay';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Employee No."; Code[20])
        {
            Caption = 'Employee No.';
            TableRelation = "Sample Employee Good";
        }
        field(2; "Annual Salary"; Decimal)
        {
            Caption = 'Annual Salary';
        }
    }

    keys
    {
        key(PK; "Employee No.") { Clustered = true; }
    }
}

page 50364 "Sample Employee Profile Good"
{
    Caption = 'Employee Profile';
    PageType = Card;
    SourceTable = "Sample Employee Good";
    ApplicationArea = All;
    Editable = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

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
    SourceTable = "Sample Employee Pay Good";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(Pay)
            {
                Caption = 'Pay';

                field("Employee No."; Rec."Employee No.") { }
                // Masked on screen against shoulder-surfing; who may open this page
                // and read the table is decided by permissions, not by the mask.
                field("Annual Salary"; Rec."Annual Salary")
                {
                    MaskType = Concealed;
                }
            }
        }
    }
}
