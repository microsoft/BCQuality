codeunit 50130 "Contoso Send Confirmation"
{
    procedure SendOrderConfirmation(ToAddress: Text; Subject: Text; Body: Text)
    var
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
    begin
        EmailMessage.Create(ToAddress, Subject, Body, true);
        Email.Send(EmailMessage, Enum::"Email Scenario"::"Sales Order");
    end;
}
