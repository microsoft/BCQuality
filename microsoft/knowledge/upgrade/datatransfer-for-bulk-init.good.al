codeunit 50218 "Upgrade Entry Codes"
{
    Subtype = Upgrade;

    local procedure CopyLegacyCode()
    var
        Entry: Record "Upgrade Entry";
        Transfer: DataTransfer;
    begin
        Transfer.SetTables(Database::"Upgrade Entry", Database::"Upgrade Entry");
        Transfer.AddSourceFilter(Entry.FieldNo("Entry No."), '>%1', 0);
        Transfer.AddFieldValue(Entry.FieldNo("Legacy Code"), Entry.FieldNo("Category Code"));
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
        field(3; "Category Code"; Code[20])
        {
            Caption = 'Category Code';
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
