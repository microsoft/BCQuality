page 50353 "WS Order API Bad"
{
    PageType = API;
    APIPublisher = 'contoso';
    APIGroup = 'sales';
    APIVersion = 'v1.0';
    EntityName = 'order';
    EntitySetName = 'orders';
    ODataKeyFields = SystemId;
    SourceTable = "Sales Header";

    layout
    {
        area(content)
        {
            repeater(records)
            {
                part(lines; "WS Order Line API Bad")
                {
                    EntityName = 'orderLine';
                    EntitySetName = 'orderLines';
                    Multiplicity = ZeroOrOne;
                    SubPageLink = "Order No." = Field("No.");
                }
            }
        }
    }
}

table 50353 "WS Order Line Bad"
{
    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Order No."; Code[20])
        {
            TableRelation = "Sales Header"."No.";
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}

page 50354 "WS Order Line API Bad"
{
    PageType = API;
    APIPublisher = 'contoso';
    APIGroup = 'sales';
    APIVersion = 'v1.0';
    EntityName = 'orderLine';
    EntitySetName = 'orderLines';
    ODataKeyFields = SystemId;
    SourceTable = "WS Order Line Bad";

    layout
    {
        area(content)
        {
            repeater(records)
            {
                field(id; Rec.SystemId)
                {
                    Editable = false;
                }
                field(orderNumber; Rec."Order No.")
                {
                }
            }
        }
    }
}
