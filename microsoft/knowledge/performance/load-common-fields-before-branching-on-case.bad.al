codeunit 50100 "Sales Document Processor"
{
    procedure DescribeDocument(DocumentType: Enum "Sales Document Type"; DocumentNo: Code[20]): Text
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetLoadFields(
            "Sell-to Customer No.",
            "Order Date", "Shipment Date", "Completely Shipped",
            "Posting Date", "Due Date", "Payment Terms Code");
        SalesHeader.Get(DocumentType, DocumentNo);

        case DocumentType of
            DocumentType::Order:
                exit(DescribeOrder(SalesHeader));
            DocumentType::Invoice:
                exit(DescribeInvoice(SalesHeader));
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
