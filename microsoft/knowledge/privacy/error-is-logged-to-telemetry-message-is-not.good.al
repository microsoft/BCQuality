codeunit 50902 "Privacy Sample ErrorVsMsg Good"
{
    procedure ConfirmThenFail(var Customer: Record Customer)
    var
        ConfirmQst: Label 'Send welcome email to %1 at %2?', Comment = '%1 = name, %2 = email';
        GenericFailureErr: Label 'The welcome email could not be sent.';
    begin
        // Confirm is not logged to telemetry. PII in the prompt is fine.
        if not Confirm(ConfirmQst, false, Customer.Name, Customer."E-Mail") then
            exit;

        // Error is logged. Keep PII out of the message.
        Error(GenericFailureErr);
    end;
}
