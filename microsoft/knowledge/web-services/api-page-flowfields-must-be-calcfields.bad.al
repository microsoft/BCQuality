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
                // No OnAfterGetRecord CalcFields — Inventory is a FlowField
                // and returns 0 to every consumer.
            }
        }
    }
}
