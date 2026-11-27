table 50345 "Sample Loyalty Wizard Setup B"
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

page 50345 "Sample Loyalty Wizard Bad"
{
    PageType = NavigatePage;
    Caption = 'Set Up Customer Loyalty';
    // Bound to the live table: each field is saved as the user types.
    SourceTable = "Sample Loyalty Wizard Setup B";

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
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert(true);
        end;
    end;
}
