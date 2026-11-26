using Microsoft.Purchases.Document;
using System.Automation;

codeunit 50181 "Purchase Workflow Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
    begin
        WorkflowEventHandling.AddEventToLibrary(PurchaseApprovalEventCodeLbl, Database::"Purchase Header", PurchaseApprovalEventDescription, 0, false);
    end;

    var
        PurchaseApprovalEventCodeLbl: Label 'SAMPLEPURCHASEAPPROVALREQUEST', Locked = true;
        PurchaseApprovalEventDescription: Label 'A purchase approval is requested.';
}

codeunit 50182 "Purchase Workflow Registration"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsePredecessorsToLibrary', '', false, false)]
    local procedure RegisterPurchaseResponsePredecessor(ResponseFunctionName: Code[128])
    var
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
    begin
        if ResponseFunctionName = WorkflowResponseHandling.CreateApprovalRequestsCode() then
            WorkflowResponseHandling.AddResponsePredecessor(ResponseFunctionName, PurchaseApprovalEventCodeLbl);
    end;

    var
        PurchaseApprovalEventCodeLbl: Label 'SAMPLEPURCHASEAPPROVALREQUEST', Locked = true;
}
