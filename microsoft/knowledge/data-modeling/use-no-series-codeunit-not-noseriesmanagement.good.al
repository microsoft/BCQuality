table 50362 "Loyalty Member"
{
    Caption = 'Loyalty Member';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            var
                NoSeries: Codeunit "No. Series";
            begin
                if "No." = xRec."No." then
                    exit;
                LoyaltySetup.Get();
                if not NoSeries.IsManual(LoyaltySetup."Member Nos.") then
                    Error(ManualNosNotAllowedErr);
                "No. Series" := '';
            end;
        }
        field(2; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    var
        LoyaltySetup: Record "Loyalty Setup";
        ManualNosNotAllowedErr: Label 'Numbers are assigned automatically. Allow manual numbers on the No. Series to enter one by hand.';

    trigger OnInsert()
    var
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
