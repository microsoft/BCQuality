codeunit 50100 "Sales Document Processor"
{
    procedure DescribeDocument(DocumentType: Enum "Sales Document Type"; DocumentNo: Code[20]): Text
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetLoadFields("Sell-to Customer No.");

        case DocumentType of
            DocumentType::Order:
                begin
                    SalesHeader.AddLoadFields("Order Date", "Shipment Date", "Completely Shipped");
                    SalesHeader.Get(DocumentType, DocumentNo);
                    exit(DescribeOrder(SalesHeader));
                end;
            DocumentType::Invoice:
                begin
                    SalesHeader.AddLoadFields("Posting Date", "Due Date", "Payment Terms Code");
                    SalesHeader.Get(DocumentType, DocumentNo);
                    exit(DescribeInvoice(SalesHeader));
                end;
        end;
    end;

    local procedure DescribeOrder(SalesHeader: Record "Sales Header"): Text
    begin
        exit(StrSubstNo('%1|%2|%3|%4', SalesHeader."Sell-to Customer No.", SalesHeader."Order Date", SalesHeader."Shipment Date", SalesHeader."Completely Shipped"));
    end;

    local procedure DescribeInvoice(SalesHeader: Record "Sales Header"): Text
    begin
        exit(StrSubstNo('%1|%2|%3|%4', SalesHeader."Sell-to Customer No.", SalesHeader."Posting Date", SalesHeader."Due Date", SalesHeader."Payment Terms Code"));
    end;
}
