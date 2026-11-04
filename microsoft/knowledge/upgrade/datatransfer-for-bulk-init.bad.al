codeunit 50219 "Upgrade Entry Flags"
{
    Subtype = Upgrade;

    local procedure InitializeMigratedFlag()
    var
        Entry: Record "Upgrade Entry";
    begin
        Entry.SetRange("Legacy Code", 'OLD');
        if Entry.FindSet(true) then
            repeat
                Entry.Migrated := true;
                Entry.Modify();
            until Entry.Next() = 0;
    end;
}

table 50222 "Upgrade Entry"
{
    Caption = 'Upgrade Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Legacy Code"; Code[20])
        {
            Caption = 'Legacy Code';
        }
        field(3; Migrated; Boolean)
        {
            Caption = 'Migrated';
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
