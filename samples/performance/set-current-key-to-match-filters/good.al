codeunit 50122 "Perf Sample SetCurrentKey Good"
{
    procedure LinesForDocument(DocumentType: Enum "Sales Document Type"; DocumentNo: Code[20]; var SalesLine: Record "Sales Line")
    begin
        SalesLine.SetCurrentKey("Document Type", "Document No.", "Line No.");
        SalesLine.SetRange("Document Type", DocumentType);
        SalesLine.SetRange("Document No.", DocumentNo);
    end;
}
