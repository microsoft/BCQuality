table 50363 "Loyalty Member"
{
    Caption = 'Loyalty Member';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin
                if "No." = xRec."No." then
                    exit;
                LoyaltySetup.Get();
                // Obsolete-pending: NoSeriesManagement.TestManual raises a
                // deprecation warning and is scheduled for removal.
                NoSeriesMgt.TestManual(LoyaltySetup."Member Nos.");
                "No. Series" := '';
            end;
        }
        field(2; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
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
        NoSeriesMgt: Codeunit NoSeriesManagement;

    trigger OnInsert()
    begin
        if "No." = '' then begin
            LoyaltySetup.Get();
            LoyaltySetup.TestField("Member Nos.");
            // Obsolete-pending legacy assignment call; use codeunit "No. Series".
            NoSeriesMgt.InitSeries(LoyaltySetup."Member Nos.", xRec."No. Series", 0D, "No.", "No. Series");
        end;
    end;
}
