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

page 50365 "Sample Employee Profile Bad"
{
    Caption = 'Employee Profile';
    PageType = Card;
    SourceTable = "Sample Employee Bad";
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
                // Every employee opens this page; the mask is relied on to keep
                // colleagues' salaries private, yet any of them can reveal it.
                field("Annual Salary"; Rec."Annual Salary")
                {
                    MaskType = Concealed;
                }
            }
        }
    }
}
