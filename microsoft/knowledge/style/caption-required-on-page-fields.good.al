// BC24 / runtime 13.0 or later for table-field tooltips.
table 50252 "Sample Caption Source"
{
    Caption = 'Caption Source';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            ToolTip = 'Specifies the customer number.';
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
            ToolTip = 'Specifies the customer name.';
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }
}

page 50252 "Sample Caption Good"
{
    PageType = Card;
    SourceTable = "Sample Caption Source";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Customer Name"; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Customer Name';
                }
                field(DisplayValue; DisplayValue)
                {
                    ApplicationArea = All;
                    Caption = 'Display Value';
                    ToolTip = 'Specifies the value to display.';
                }
            }
        }
    }

    var
        DisplayValue: Text[100];
}
