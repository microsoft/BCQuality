table 50370 "Loyalty Member"
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
        // Blocked is inert data here: the master carries the flag but no logic.
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
}

table 50371 "Loyalty Point Entry"
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

            trigger OnValidate()
            var
                LoyaltyMember: Record "Loyalty Member";
            begin
                if "Member No." = '' then
                    exit;
                // Enforcement lives at the point of use: reject a blocked master
                // as soon as a line references it.
                LoyaltyMember.Get("Member No.");
                LoyaltyMember.TestField(Blocked, false);
            end;
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

    procedure Post()
    var
        LoyaltyMember: Record "Loyalty Member";
    begin
        // Re-check before committing the transaction, in case the member was
        // blocked after the line was created.
        LoyaltyMember.Get("Member No.");
        LoyaltyMember.TestField(Blocked, false);
    end;
}
