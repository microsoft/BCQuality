page 50350 "WS Bound Action Good"
{
    PageType = API;
    Caption = 'salesOrder';
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
            }
        }
    }

    [ServiceEnabled]
    procedure Post(var ActionContext: WebServiceActionContext)
    var
        PostHelper: Codeunit "WS Bound Action Helper";
    begin
        PostHelper.PostOrder(Rec);
        SetActionResponse(ActionContext, Rec.SystemId);
    end;

    local procedure SetActionResponse(var ActionContext: WebServiceActionContext; CreatedId: Guid)
    begin
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"WS Bound Action Good");
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), CreatedId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;
}

codeunit 50352 "WS Bound Action Helper"
{
    procedure PostOrder(var SalesHeader: Record "Sales Header")
    var
        SalesPost: Codeunit "Sales-Post";
    begin
        SalesPost.Run(SalesHeader);
    end;
}
