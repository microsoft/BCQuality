// Neither the name CreditNote nor its caption changes in place: schema 2.0 consumers bind to the name,
// schema 1.0 consumers to the caption. A new kind is appended; a retired kind is obsoleted, never deleted.
enum 50120 "Document Kind Good"
{
    Extensible = true;

    value(0; Invoice) { Caption = 'Invoice'; }
    value(1; Order) { Caption = 'Order'; }
    value(2; CreditNote) { Caption = 'Credit Note'; }
    value(3; ReturnOrder) { Caption = 'Return Order'; }
    value(4; Quote) { Caption = 'Quote'; ObsoleteState = Pending; ObsoleteReason = 'Quotes moved to the quotes API.'; ObsoleteTag = '3.0'; }
}

table 50121 "Document Header Good"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20]) { DataClassification = CustomerContent; }
        field(2; Kind; Enum "Document Kind Good") { DataClassification = CustomerContent; }
    }

    keys
    {
        key(PK; "No.") { Clustered = true; }
    }
}

page 50122 "Document API Good"
{
    PageType = API;
    APIPublisher = 'contoso';
    APIGroup = 'documents';
    APIVersion = 'v1.0';
    EntityName = 'document';
    EntitySetName = 'documents';
    ODataKeyFields = SystemId;
    SourceTable = "Document Header Good";
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
