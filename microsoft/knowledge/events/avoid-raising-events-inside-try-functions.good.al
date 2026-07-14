// Demonstration only. Shows the correct pattern: raise the integration event before entering TryFunction.

codeunit 50114 "Payment Processor"
{
    [IntegrationEvent(false, false)]
    procedure OnBeforeSubmitPayment(var PaymentAmount: Decimal; var Cancel: Boolean)
    begin
    end;

    procedure SubmitPayment(PaymentAmount: Decimal)
    var
        Cancel: Boolean;
        Success: Boolean;
    begin
        Cancel := false;
        // Event raised outside the try scope - subscriber errors propagate normally to the caller.
        OnBeforeSubmitPayment(PaymentAmount, Cancel);
        if Cancel then
            exit;

        // Only the operation that can fail transiently lives inside TryFunction.
        Success := TryCallPaymentGateway(PaymentAmount);
        if not Success then
            Error('Payment gateway call failed. Check connectivity and retry.');
    end;

    [TryFunction]
    local procedure TryCallPaymentGateway(PaymentAmount: Decimal)
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
    begin
        // ... build request, set headers ...
        Client.Get('https://payments.example.com/submit?amount=' + Format(PaymentAmount), Response);
        if not Response.IsSuccessStatusCode() then
            Error('HTTP %1', Response.HttpStatusCode());
    end;
}
