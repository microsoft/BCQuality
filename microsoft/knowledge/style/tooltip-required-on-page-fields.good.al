// BC24 / runtime 13.0 or later.
table 50250 "Sample Tooltip Source"
{
    Caption = 'Tooltip Source';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            ToolTip = 'Specifies the number that identifies the entry.';
        }
        field(2; Amount; Decimal)
        {
            Caption = 'Amount';
            ToolTip = 'Specifies the entry amount.';
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

page 50250 "Sample Tooltip Good"
{
    PageType = Card;
    SourceTable = "Sample Tooltip Source";
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
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry amount to use in the preview.';
                }
                field(PreviewAmount; PreviewAmount)
                {
                    ApplicationArea = All;
                    Caption = 'Preview Amount';
                    ToolTip = 'Specifies the amount to preview before saving.';
                }
            }
        }
    }

    var
        PreviewAmount: Decimal;
}
