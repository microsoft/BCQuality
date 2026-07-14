codeunit 50301 "Try Return Bad"
{
    procedure ImportDocument()
    begin
        // Ignoring the Boolean result makes this an ordinary, throwing call.
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
