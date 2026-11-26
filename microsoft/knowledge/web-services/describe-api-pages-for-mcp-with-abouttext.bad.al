// Intended for exposure through the Business Central online MCP server.
page 50381 "WS Margin Line API Bad"
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
query 50383 "WS Item Lines Query Bad"
{
    QueryType = API;
    APIPublisher = 'contoso';
    APIGroup = 'salesMargin';
    APIVersion = 'v1.0';
    EntityName = 'itemSalesLine';
    EntitySetName = 'itemSalesLines';
    EntityCaption = 'Item Sales Line';
    EntitySetCaption = 'Item Sales Lines';
    // The entity caption omits the material document-type scope.
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
