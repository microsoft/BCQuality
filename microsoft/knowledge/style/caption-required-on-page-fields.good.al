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
            ToolTip = 'Specifies the unique number used to distinguish this customer record from other records.';
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
            ToolTip = 'Specifies the name used to identify the customer alongside the unique customer number.';
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
                    ToolTip = 'Specifies temporary text for this page; the text is not saved in the customer record.';
                }
            }
        }
    }

    var
        DisplayValue: Text[100];
}
