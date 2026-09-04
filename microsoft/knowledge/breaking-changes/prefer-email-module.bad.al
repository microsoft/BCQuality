codeunit 50103 "Order Confirmation Notifier"
{
    procedure Send(FromName: Text; ToAddress: Text; Subject: Text; Body: Text)
    var
        Mail: Codeunit Mail;
        MailSent: Boolean;
    begin
        Mail.CreateMessage(FromName, ToAddress, '', Subject, Body, true);
        MailSent := Mail.Send();
        if not MailSent then
            Message(Mail.GetErrorDesc());
    end;
}
