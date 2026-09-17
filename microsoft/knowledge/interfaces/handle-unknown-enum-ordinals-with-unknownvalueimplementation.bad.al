// Demonstration-only AL. A removed enum-extension value left ordinal 700 in data.
enum 50503 "Delivery Method Bad" implements "I Delivery Method Bad"
{
    Extensible = true;
    DefaultImplementation = "I Delivery Method Bad" = "Default Delivery Method Bad";

    value(0; Default)
    {
    }
}

interface "I Delivery Method Bad"
{
    procedure Deliver();
}

codeunit 50504 "Default Delivery Method Bad" implements "I Delivery Method Bad"
{
    procedure Deliver()
    begin
    end;
}

codeunit 50505 "Delivery Dispatch Bad"
{
    procedure DeliverPersistedValue()
    var
        DeliveryMethod: Enum "Delivery Method Bad";
        Delivery: Interface "I Delivery Method Bad";
    begin
        DeliveryMethod := 700;
        // DefaultImplementation does not handle an ordinal that is not declared.
        Delivery := DeliveryMethod;
        Delivery.Deliver();
    end;
}
