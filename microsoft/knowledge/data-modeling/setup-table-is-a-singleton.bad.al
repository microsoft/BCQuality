table 50366 "Loyalty Setup"
{
    Caption = 'Loyalty Setup';
    DataClassification = CustomerContent;

    fields
    {
        // Anti-pattern: an autoincrement key lets the table hold many rows,
        // so "the setup" is no longer a single, well-known record.
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(10; "Member Nos."; Code[20])
        {
            Caption = 'Member Nos.';
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}

page 50367 "Loyalty Setup List"
{
    // Anti-pattern: a List page over a setup table invites multiple rows and
    // never guarantees that a row exists to read.
    Caption = 'Loyalty Setup List';
    PageType = List;
    SourceTable = "Loyalty Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Member Nos."; Rec."Member Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number series used to assign member numbers.';
                }
            }
        }
    }
}
