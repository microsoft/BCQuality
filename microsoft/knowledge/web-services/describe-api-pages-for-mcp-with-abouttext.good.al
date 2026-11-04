// Intended for exposure through the Business Central online MCP server.
page 50380 "WS Margin Line API Good"
{
    PageType = API;
    Caption = 'marginLine';
    APIPublisher = 'contoso';
    APIGroup = 'salesMargin';
    APIVersion = 'v1.0';
    EntityName = 'marginLine';
    EntitySetName = 'marginLines';
    EntityCaption = 'Margin Line';
    EntitySetCaption = 'Margin Lines';
    AboutText = 'One item line of an unposted sales quote, order or invoice, with its document number, item and line amount. Read-only; credit memos and non-item lines are not included.';
    ODataKeyFields = SystemId;
    SourceTable = "Sales Line";
    SourceTableView = where("Document Type" = filter(Quote | Order | Invoice), Type = const(Item));
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(records)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'id';
                    Editable = false;
                }
                field(documentNumber; Rec."Document No.")
                {
                    Caption = 'documentNumber';
                }
                field(itemNumber; Rec."No.")
                {
                    Caption = 'itemNumber';
                }
                field(lineAmount; Rec."Line Amount")
                {
                    Caption = 'lineAmount';
                }
            }
        }
    }
}

// This API query is also intended for exposure as an MCP tool.
query 50382 "WS Item Lines Query Good"
{
    QueryType = API;
    APIPublisher = 'contoso';
    APIGroup = 'salesMargin';
    APIVersion = 'v1.0';
    EntityName = 'itemSalesLine';
    EntitySetName = 'itemSalesLines';
    EntityCaption = 'Item Sales Line';
    EntitySetCaption = 'Item Sales Lines';
    AboutText = 'One item line of an unposted sales quote, order or invoice. Credit memos and non-item lines are excluded; returns the line ID, document number and item number.';
    elements
    {
        dataitem(SalesLine; "Sales Line")
        {
            DataItemTableFilter = "Document Type" = filter(Quote | Order | Invoice), Type = const(Item);
            column(id; SystemId) { }
            column(documentNumber; "Document No.") { }
            column(itemNumber; "No.") { }
        }
    }
}
