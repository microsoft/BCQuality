xmlport 50333 "Sample Item Export Bad"
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

codeunit 50333 "Sample Item Export Runner Bad"
{
    procedure ExportItems()
    begin
        // Import is omitted and defaults to true, which contradicts Direction = Export.
        Xmlport.Run(Xmlport::"Sample Item Export Bad", false);
    end;
}
