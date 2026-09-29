codeunit 50161 "Cancel External Quotes Bad"
{
    procedure CancelQuote(ExternalDocumentNo: Text)
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Quote);
        SalesHeader.SetFilter("External Document No.", ExternalDocumentNo);
        SalesHeader.DeleteAll(true);
    end;
}
