codeunit 50114 "SCM Additional Promise Bad"
{
    procedure CanPromiseAdditionalDemand(ItemNo: Code[20]; LocationCode: Code[10]; VariantCode: Code[10]; ShipmentDate: Date; RequestedAdditionalQuantityBase: Decimal; LookaheadDateFormula: DateFormula): Boolean
    var
        Item: Record Item;
    begin
        if (ShipmentDate = 0D) or (RequestedAdditionalQuantityBase <= 0) then
            Error(DemandInputErr);
        Item.Get(ItemNo);
        Item.TestField(Type, Item.Type::Inventory);
        Item.SetRange("Location Filter", LocationCode);
        Item.SetRange("Variant Filter", VariantCode);
        Item.SetRange("Date Filter", 0D, ShipmentDate);

        Item.CalcFields(Inventory);
        exit(Item.Inventory >= RequestedAdditionalQuantityBase);
    end;

    var
        DemandInputErr: Label 'Enter a shipment date and a positive additional base quantity.';
}
