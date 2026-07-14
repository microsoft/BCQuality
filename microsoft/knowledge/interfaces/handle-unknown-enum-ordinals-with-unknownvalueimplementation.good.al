// Demonstration-only AL. UnknownValueImplementation requires runtime 7.0 / BC18.
interface "I Delivery Method"
{
    procedure Deliver();
}

codeunit 50500 "Unknown Delivery Method" implements "I Delivery Method"
{
    procedure Deliver()
    begin
        Error(UnknownMethodErr);
    end;

    var
        UnknownMethodErr: Label 'The saved delivery method is no longer installed. Select another method.';
}

codeunit 50501 "Default Delivery Method" implements "I Delivery Method"
{
    procedure Deliver()
    begin
    end;
}

enum 50502 "Delivery Method" implements "I Delivery Method"
{
    Extensible = true;
    DefaultImplementation = "I Delivery Method" = "Default Delivery Method";
    UnknownValueImplementation = "I Delivery Method" = "Unknown Delivery Method";

    value(0; Default)
    {
    }
}
