codeunit 50301 "Try Return Bad"
{
    procedure ImportDocument(): Boolean
    begin
        // The bare call is not a try-method call: the error stops this procedure here,
        // so the check below never sees it.
        TryImportDocument();
        if GetLastErrorText() <> '' then
            exit(false);
        exit(true);
    end;

    [TryFunction]
    local procedure TryImportDocument()
    begin
        Error(SourceRejectedErr);
    end;

    var
        SourceRejectedErr: Label 'The source document was rejected.';
}
