// Ordinal 2 was renamed from CreditNote to CreditMemo with ordinal and caption kept. The compiler stays silent
// and AS0082 fires only against a baseline; every schema 2.0 consumer that filters on or posts CreditNote fails.
enum 50120 "Document Kind Bad"
{
    Extensible = true;

    value(0; Invoice) { Caption = 'Invoice'; }
    value(1; Order) { Caption = 'Order'; }
    value(2; CreditMemo) { Caption = 'Credit Memo'; }
}

table 50121 "Document Header Bad"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20]) { DataClassification = CustomerContent; }
        field(2; Kind; Enum "Document Kind Bad") { DataClassification = CustomerContent; }
    }

    keys
    {
        key(PK; "No.") { Clustered = true; }
    }
}

page 50122 "Document API Bad"
{
    PageType = API;
    APIPublisher = 'contoso';
    APIGroup = 'documents';
    APIVersion = 'v1.0';
    EntityName = 'document';
    EntitySetName = 'documents';
    ODataKeyFields = SystemId;
    SourceTable = "Document Header Bad";
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(records)
            {
                field(id; Rec.SystemId) { Caption = 'id'; Editable = false; }
                field(number; Rec."No.") { Caption = 'number'; }
                field(kind; Rec.Kind) { Caption = 'kind'; }
            }
        }
    }
}
