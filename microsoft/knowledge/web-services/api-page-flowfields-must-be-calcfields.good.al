page 50100 "Item Availability API"
{
    PageType = API;
    APIPublisher = 'contoso';
    APIGroup = 'inventory';
    APIVersion = 'v1.0';
    EntityName = 'itemAvailability';
    EntitySetName = 'itemAvailabilities';
    SourceTable = Item;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(itemNo; Rec."No.") { }
                field(quantityOnHand; Rec.Inventory) { }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields(Inventory);
    end;
}
