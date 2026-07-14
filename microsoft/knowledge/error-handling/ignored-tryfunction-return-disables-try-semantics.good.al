codeunit 50300 "Try Return Good"
{
    procedure ImportDocument()
    begin
        if not TryImportDocument() then
            Error(ImportFailedErr);
    end;

    [TryFunction]
    local procedure TryImportDocument()
    begin
        Error(SourceRejectedErr);
    end;

    var
        ImportFailedErr: Label 'The document could not be imported.';
        SourceRejectedErr: Label 'The source document was rejected.';
}
