xmlport 50332 "Sample Item Export Good"
{
    Caption = 'Sample Item Export';
    Direction = Export;
    Format = Xml;

    schema
    {
        textelement(Items)
        {
            tableelement(Item; Item)
            {
                fieldelement(No; Item."No.") { }
                fieldelement(Description; Item.Description) { }
            }
        }
    }
}

codeunit 50332 "Sample Item Export Runner Good"
{
    procedure ExportItems()
    begin
        // No request page, and Import = false to match Direction = Export.
        Xmlport.Run(Xmlport::"Sample Item Export Good", false, false);
    end;
}
