// Demonstration only. Shows the wrong pattern: raising the integration event inside a TryFunction body.

codeunit 50116 "Payment Processor Bad"
{
    [IntegrationEvent(false, false)]
    procedure OnBeforeSubmitPayment(var PaymentAmount: Decimal; var Cancel: Boolean)
    begin
    end;

    procedure SubmitPayment(PaymentAmount: Decimal)
    var
        Success: Boolean;
    begin
        // TryFunction wraps both the event raise and the gateway call.
        Success := TrySubmitPaymentInternal(PaymentAmount);
        if not Success then
            Error('Payment gateway call failed. Check connectivity and retry.');
    end;

    [TryFunction]
    local procedure TrySubmitPaymentInternal(PaymentAmount: Decimal)
    var
        Cancel: Boolean;
        Client: HttpClient;
        Response: HttpResponseMessage;
    begin
        Cancel := false;
        // BAD: event raised inside TryFunction. Any Error() thrown by a subscriber is caught here
        // and silently swallowed - the subscriber's error never reaches the caller.
        // A subscriber setting Cancel := true is also lost when TryFunction returns false.
        OnBeforeSubmitPayment(PaymentAmount, Cancel);
        if Cancel then
            exit;
        Client.Get('https://payments.example.com/submit?amount=' + Format(PaymentAmount), Response);
        if not Response.IsSuccessStatusCode() then
            Error('HTTP %1', Response.HttpStatusCode());
    end;
}
