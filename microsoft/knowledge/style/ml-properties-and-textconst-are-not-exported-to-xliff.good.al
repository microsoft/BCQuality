table 50320 "Sample Loyalty Setup Good"
{
    Caption = 'Loyalty Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Loyalty Level"; Option)
        {
            Caption = 'Loyalty Level';
            OptionMembers = None,Silver,Gold;
            OptionCaption = 'None,Silver,Gold';
            ToolTip = 'Specifies the loyalty level that new customers start with.';
        }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }

    procedure CheckLevel()
    begin
        if "Loyalty Level" = "Loyalty Level"::None then
            Error(LevelMissingErr);
    end;

    var
        LevelMissingErr: Label 'Select a loyalty level.';
}
