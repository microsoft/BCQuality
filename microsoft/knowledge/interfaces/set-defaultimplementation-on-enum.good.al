interface INotifier
{
    procedure Send(Recipient: Text; Body: Text): Boolean;
}

codeunit 50206 "Email Notifier" implements INotifier
{
    procedure Send(Recipient: Text; Body: Text): Boolean
    begin
        // A real implementation would hand the message to an email service.
        exit(Recipient <> '');
    end;
}

codeunit 50207 "Default Notifier" implements INotifier
{
    procedure Send(Recipient: Text; Body: Text): Boolean
    begin
        // Safe fallback so an unmapped or future channel still resolves to a
        // usable object instead of failing where the interface is called.
        exit(false);
    end;
}

enum 50208 "Notification Channel" implements INotifier
{
    Extensible = true;
    DefaultImplementation = INotifier = "Default Notifier";

    value(0; Email)
    {
        Implementation = INotifier = "Email Notifier";
    }
    value(1; None)
    {
        // No explicit Implementation: resolves to DefaultImplementation above.
    }
}

codeunit 50209 "Notification Dispatch"
{
    procedure Notify(Channel: Enum "Notification Channel"; Recipient: Text; Body: Text): Boolean
    var
        Notifier: Interface INotifier;
    begin
        Notifier := Channel;
        exit(Notifier.Send(Recipient, Body));
    end;
}
