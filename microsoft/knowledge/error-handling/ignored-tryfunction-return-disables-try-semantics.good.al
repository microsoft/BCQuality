codeunit 50300 "Try Return Good"
{
    procedure ImportDocument(): Boolean
    begin
        // The caller continues on failure, so the result is consumed.
        if not TryImportDocument() then
            exit(false);
        exit(true);
    end;

    procedure ImportRequiredDocument()
    begin
        // The error should reach the user, so a bare call is correct.
        TryImportDocument();
    end;

    [TryFunction]
    local procedure TryImportDocument()
    begin
        Error(SourceRejectedErr);
    end;

    var
        SourceRejectedErr: Label 'The source document was rejected.';
}
