codeunit 50218 "Upgrade Entry Flags"
{
    Subtype = Upgrade;

    local procedure InitializeMigratedFlag()
    var
        Entry: Record "Upgrade Entry";
        Transfer: DataTransfer;
    begin
        Transfer.SetTables(Database::"Upgrade Entry", Database::"Upgrade Entry");
        Transfer.AddSourceFilter(Entry.FieldNo("Legacy Code"), '=%1', 'OLD');
        Transfer.AddConstantValue(true, Entry.FieldNo(Migrated));
        Transfer.CopyFields();
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
