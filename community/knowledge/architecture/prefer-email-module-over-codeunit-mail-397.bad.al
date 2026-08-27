codeunit 50130 "Contoso Send Confirmation"
{
    procedure SendOrderConfirmation(FromName: Text; ToAddress: Text; Subject: Text; Body: Text)
    var
        Mail: Codeunit Mail;
    begin
        // Hard-coded to whatever SMTP account is configured; no Sent/Outbox
        // record is left once this call returns.
        Mail.CreateMessage(FromName, ToAddress, '', Subject, Body, true);
        if not Mail.Send() then
            Message(Mail.GetErrorDesc());
    end;
}
