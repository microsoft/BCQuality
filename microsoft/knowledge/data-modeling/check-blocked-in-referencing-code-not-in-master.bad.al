table 50372 "Loyalty Member"
{
    Caption = 'Loyalty Member';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(10; Name; Text[100])
        {
            Caption = 'Name';
        }
        field(20; Blocked; Boolean)
        {
            Caption = 'Blocked';
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    // Anti-pattern: the block check sits in the master's own trigger. Editing a
    // blocked member is rare; referencing it is constant, and references never
    // fire OnModify. So this stops nothing that matters.
    trigger OnModify()
    begin
        TestField(Blocked, false);
    end;
}

table 50373 "Loyalty Point Entry"
{
    Caption = 'Loyalty Point Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(10; "Member No."; Code[20])
        {
            Caption = 'Member No.';
            TableRelation = "Loyalty Member"."No.";
            // No block check on the referencing side: a line can freely
            // reference a blocked member, and posting proceeds unchecked.
        }
        field(20; Points; Integer)
        {
            Caption = 'Points';
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
