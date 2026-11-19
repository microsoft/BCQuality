table 50344 "Sample Loyalty Wizard Setup"
{
    Caption = 'Loyalty Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10]) { Caption = 'Primary Key'; }
        field(2; "Points per Amount"; Decimal) { Caption = 'Points per Amount'; }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }
}

page 50344 "Sample Loyalty Wizard Good"
{
    PageType = NavigatePage;
    Caption = 'Set Up Customer Loyalty';
    SourceTable = "Sample Loyalty Wizard Setup";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            group(Points)
            {
                Caption = 'How many points does a customer earn?';

                field("Points per Amount"; Rec."Points per Amount")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Finish)
            {
                ApplicationArea = All;
                Caption = '&Finish';
                InFooterBar = true;
                Image = Approve;

                trigger OnAction()
                begin
                    SaveSetup();
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Init();
        Rec.Insert(false);
    end;

    local procedure SaveSetup()
    var
        LoyaltySetup: Record "Sample Loyalty Wizard Setup";
    begin
        // The only write to the database, and it happens when the user finishes.
        if not LoyaltySetup.Get() then begin
            LoyaltySetup.Init();
            LoyaltySetup.Insert(true);
        end;
        LoyaltySetup."Points per Amount" := Rec."Points per Amount";
        LoyaltySetup.Modify(true);
    end;
}
