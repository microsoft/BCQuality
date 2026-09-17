page 50350 "WS Order API"
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
                field(id; Rec.SystemId)
                {
                    Editable = false;
                }
                part(lines; "WS Order Line API")
                {
                    EntityName = 'orderLine';
                    EntitySetName = 'orderLines';
                    SubPageLink = "Order Id" = Field(SystemId);
                }
                part(summary; "WS Order Summary API")
                {
                    EntityName = 'orderSummary';
                    Multiplicity = ZeroOrOne;
                    SubPageLink = "Order Id" = Field(SystemId);
                }
            }
        }
    }
}

table 50350 "WS Order Line"
{
    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Order Id"; Guid)
        {
            TableRelation = "Sales Header".SystemId;
        }
        field(3; Description; Text[100])
        {
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

table 50351 "WS Order Summary"
{
    fields
    {
        field(1; "Order Id"; Guid)
        {
            TableRelation = "Sales Header".SystemId;
        }
        field(2; Summary; Text[100])
        {
        }
    }

    keys
    {
        key(PK; "Order Id")
        {
            Clustered = true;
        }
    }
}

page 50351 "WS Order Line API"
{
    PageType = API;
    APIPublisher = 'contoso';
    APIGroup = 'sales';
    APIVersion = 'v1.0';
    EntityName = 'orderLine';
    EntitySetName = 'orderLines';
    ODataKeyFields = SystemId;
    SourceTable = "WS Order Line";
    DelayedInsert = true;

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
                field(orderId; Rec."Order Id")
                {
                }
                field(description; Rec.Description)
                {
                }
            }
        }
    }
}

page 50352 "WS Order Summary API"
{
    PageType = API;
    APIPublisher = 'contoso';
    APIGroup = 'sales';
    APIVersion = 'v1.0';
    EntityName = 'orderSummary';
    EntitySetName = 'orderSummaries';
    ODataKeyFields = SystemId;
    SourceTable = "WS Order Summary";
    DelayedInsert = true;

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
                field(orderId; Rec."Order Id")
                {
                }
                field(summary; Rec.Summary)
                {
                }
            }
        }
    }
}
