codeunit 50160 "Cancel External Quotes Good"
{
    procedure CancelQuote(ExternalDocumentNo: Code[35])
    var
        SalesHeader: Record "Sales Header";
    begin
        if ExternalDocumentNo = '' then
            Error(MissingExternalDocumentNoErr);

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Quote);
        SalesHeader.SetRange("External Document No.", ExternalDocumentNo);
        SalesHeader.DeleteAll(true);
    end;

    procedure CancelQuotes(ExternalDocumentNos: List of [Code[35]])
    var
        ExternalDocumentNo: Code[35];
    begin
        foreach ExternalDocumentNo in ExternalDocumentNos do
            CancelQuote(ExternalDocumentNo);
    end;

    var
        MissingExternalDocumentNoErr: Label 'The external document number is missing.';
}
