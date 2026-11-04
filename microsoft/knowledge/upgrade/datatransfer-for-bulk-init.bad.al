codeunit 50219 "Upgrade Entry Codes"
{
    Subtype = Upgrade;

    local procedure CopyLegacyCode()
    var
        Entry: Record "Upgrade Entry";
    begin
        Entry.SetFilter("Entry No.", '>%1', 0);
        if Entry.FindSet(true) then
            repeat
                Entry."Category Code" := Entry."Legacy Code";
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
