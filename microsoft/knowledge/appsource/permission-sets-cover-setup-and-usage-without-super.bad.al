table 50476 "Rental Setup Bad"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10]) { }
    }
}

page 50477 "Rental Setup Bad"
{
    PageType = Card;
    SourceTable = "Rental Setup Bad";

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

codeunit 50478 "Rental Setup Mgt. Bad"
{
    procedure Initialize()
    begin
    end;
}

permissionset 50479 "Rental User"
{
    Assignable = true;
    // The setup page opens, but saving or running setup logic requires SUPER.
    Permissions =
        page "Rental Setup Bad" = X;
}
