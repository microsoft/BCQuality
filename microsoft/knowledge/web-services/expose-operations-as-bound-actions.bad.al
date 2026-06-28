// Side effect hidden behind a writable flag: PATCHing "posted" to true silently
// triggers posting through OnValidate. The operation is indistinguishable from
// an ordinary data edit and is not discoverable as an action. Expose a
// [ServiceEnabled] bound action instead.
page 50351 "WS Bound Action Bad"
{
    PageType = API;
    APIPublisher = 'contoso';
    APIGroup = 'sales';
    APIVersion = 'v1.0';
    EntityName = 'salesOrder';
    EntitySetName = 'salesOrders';
    ODataKeyFields = SystemId;
    SourceTable = "Sales Header";
    DelayedInsert = true;

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
                field(number; Rec."No.")
                {
                    Caption = 'number';
                }
                field(posted; IsPosted)
                {
                    Caption = 'posted';

                    trigger OnValidate()
                    var
                        PostHelper: Codeunit "WS Bound Action Bad Helper";
                    begin
                        if IsPosted then
                            PostHelper.PostOrder(Rec);
                    end;
                }
            }
        }
    }

    var
        IsPosted: Boolean;
}

codeunit 50353 "WS Bound Action Bad Helper"
{
    procedure PostOrder(var SalesHeader: Record "Sales Header")
    var
        SalesPost: Codeunit "Sales-Post";
    begin
        SalesPost.Run(SalesHeader);
    end;
}
