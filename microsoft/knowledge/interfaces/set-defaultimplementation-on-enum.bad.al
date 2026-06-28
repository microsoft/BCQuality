interface INotifier
{
    procedure Send(Recipient: Text; Body: Text): Boolean;
}

codeunit 50210 "Email Notifier Bad" implements INotifier
{
    procedure Send(Recipient: Text; Body: Text): Boolean
    begin
        exit(Recipient <> '');
    end;
}

enum 50211 "Notification Channel Bad" implements INotifier
{
    Extensible = true;
    // No DefaultImplementation declared.

    value(0; Email)
    {
        Implementation = INotifier = "Email Notifier Bad";
    }
    value(1; None)
    {
        // No Implementation here and no enum-level DefaultImplementation:
        // resolving this value to INotifier and calling Send fails at runtime.
    }
}

codeunit 50212 "Notification Dispatch Bad"
{
    procedure Notify(Channel: Enum "Notification Channel Bad"; Recipient: Text; Body: Text): Boolean
    var
        Notifier: Interface INotifier;
    begin
        Notifier := Channel;                    // Channel::None has no implementation
        exit(Notifier.Send(Recipient, Body));   // runtime failure for the None value
    end;
}
