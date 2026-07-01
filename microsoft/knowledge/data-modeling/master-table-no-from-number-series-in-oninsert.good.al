table 50360 "Loyalty Member"
{
    Caption = 'Loyalty Member';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(2; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(10; Name; Text[100])
        {
            Caption = 'Name';
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        LoyaltySetup: Record "Loyalty Setup";
        NoSeries: Codeunit "No. Series";
    begin
        if "No." = '' then begin
            LoyaltySetup.Get();
            LoyaltySetup.TestField("Member Nos.");
            "No. Series" := LoyaltySetup."Member Nos.";
            "No." := NoSeries.GetNextNo("No. Series");
        end;
    end;
}
