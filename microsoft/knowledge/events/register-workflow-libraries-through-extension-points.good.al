using Microsoft.Purchases.Document;
using System.Automation;

codeunit 50180 "Purchase Workflow Registration"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', false, false)]
    local procedure RegisterPurchaseWorkflowEvent()
    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
    begin
        WorkflowEventHandling.AddEventToLibrary(PurchaseApprovalEventCode(), Database::"Purchase Header", PurchaseApprovalEventDescription, 0, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsePredecessorsToLibrary', '', false, false)]
    local procedure RegisterPurchaseResponsePredecessor(ResponseFunctionName: Code[128])
    var
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
    begin
        if ResponseFunctionName = WorkflowResponseHandling.CreateApprovalRequestsCode() then
            WorkflowResponseHandling.AddResponsePredecessor(ResponseFunctionName, PurchaseApprovalEventCode());
    end;

    local procedure PurchaseApprovalEventCode(): Code[128]
    begin
        exit(PurchaseApprovalEventCodeLbl);
    end;

    var
        PurchaseApprovalEventCodeLbl: Label 'SAMPLEPURCHASEAPPROVALREQUEST', Locked = true;
        PurchaseApprovalEventDescription: Label 'A purchase approval is requested.';
}
