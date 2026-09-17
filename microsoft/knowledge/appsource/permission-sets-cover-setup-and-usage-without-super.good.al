table 50472 "Rental Setup"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10]) { }
    }
}

page 50473 "Rental Setup"
{
    PageType = Card;
    SourceTable = "Rental Setup";

    layout
    {
        area(Content)
        {
            field("Primary Key"; Rec."Primary Key")
            {
                ApplicationArea = All;
                Caption = 'Primary Key';
                ToolTip = 'Specifies the setup record.';
            }
        }
    }
}

codeunit 50474 "Rental Setup Mgt."
{
    procedure Initialize()
    begin
    end;
}

permissionset 50475 "Rental Manager"
{
    Assignable = true;
    Permissions =
        tabledata "Rental Setup" = RIMD,
        table "Rental Setup" = X,
        page "Rental Setup" = X,
        codeunit "Rental Setup Mgt." = X;
}
