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
            ToolTip = 'Specifies the unique number used to distinguish this entry from other entries.';
        }
        field(2; Amount; Decimal)
        {
            Caption = 'Amount';
            ToolTip = 'Specifies the monetary value recorded for this entry; changing it updates the saved entry.';
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
                    ToolTip = 'Specifies the recorded amount to compare with the temporary preview amount.';
                }
                field(PreviewAmount; PreviewAmount)
                {
                    ApplicationArea = All;
                    Caption = 'Preview Amount';
                    ToolTip = 'Specifies a temporary amount to compare with the recorded entry amount; this value is not saved.';
                }
            }
        }
    }

    var
        PreviewAmount: Decimal;
}
