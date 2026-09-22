codeunit 50103 "Order Confirmation Notifier"
{
    procedure Send(ToAddress: Text; Subject: Text; Body: Text)
    var
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
    begin
        EmailMessage.Create(ToAddress, Subject, Body, true);
        Email.Send(EmailMessage, Enum::"Email Scenario"::Default);
    end;
}
