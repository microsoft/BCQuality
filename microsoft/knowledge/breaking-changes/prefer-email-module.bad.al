codeunit 50103 "Order Confirmation Notifier"
{
    procedure Send(ToAddress: Text; Subject: Text; Body: Text)
    var
        Mail: Codeunit Mail;
    begin
        Mail.CreateMessage(ToAddress, '', '', Subject, Body, false, false);
    end;
}
