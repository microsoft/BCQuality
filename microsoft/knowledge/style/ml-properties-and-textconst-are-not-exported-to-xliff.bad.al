table 50321 "Sample Loyalty Setup Bad"
{
    CaptionML = ENU = 'Loyalty Setup', DAN = 'Loyalitetsopsætning';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            CaptionML = ENU = 'Primary Key', DAN = 'Primærnøgle';
        }
        field(2; "Loyalty Level"; Option)
        {
            CaptionML = ENU = 'Loyalty Level', DAN = 'Loyalitetsniveau';
            OptionMembers = None,Silver,Gold;
            OptionCaptionML = ENU = 'None,Silver,Gold', DAN = 'Ingen,Sølv,Guld';
            ToolTipML = ENU = 'Specifies the loyalty level that new customers start with.';
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
        LevelMissingErr: TextConst ENU = 'Select a loyalty level.', DAN = 'Vælg et loyalitetsniveau.';
}
