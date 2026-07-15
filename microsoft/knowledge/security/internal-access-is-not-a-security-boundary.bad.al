codeunit 50471 "Unprotected Setup Action"
{
    Access = Internal;

    trigger OnRun()
    begin
        // Internal does not prevent another extension from invoking this OnRun
        // through Codeunit.Run.
        UpdateSensitiveSetup();
    end;

    local procedure UpdateSensitiveSetup()
    begin
    end;
}
