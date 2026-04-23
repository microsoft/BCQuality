codeunit 50903 "Privacy Sample ErrorVsMsg Bad"
{
    procedure ConfirmThenFail(var Customer: Record Customer)
    var
        ConfirmQst: Label 'Send welcome email to %1 at %2?', Comment = '%1 = name, %2 = email';
        FailureWithPiiErr: Text;
    begin
        if not Confirm(ConfirmQst, false, Customer.Name, Customer."E-Mail") then
            exit;

        // Pre-built Text with PII, passed to Error: customer name and email reach telemetry.
        FailureWithPiiErr := StrSubstNo(
            'Could not send welcome to %1 at %2.', Customer.Name, Customer."E-Mail");
        Error(FailureWithPiiErr);
    end;
}
