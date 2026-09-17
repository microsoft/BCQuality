namespace BCQuality.SCM.Samples;

using Microsoft.Inventory.Requisition;
using Microsoft.Purchases.Document;
using Microsoft.Sales.Document;

codeunit 50117 "SCM Requisition Action Good"
{
    procedure CarryOutAcceptedNewPurchase(TemplateName: Code[10]; BatchName: Code[10]; LineNo: Integer; OrderDate: Date; PostingDate: Date; ReceiptDate: Date; CutoffDate: Date)
    var
        RequisitionLine: Record "Requisition Line";
        PurchaseHeaderDefaults: Record "Purchase Header";
        ReqWkshMakeOrder: Codeunit "Req. Wksh.-Make Order";
    begin
        if (OrderDate = 0D) or (PostingDate = 0D) or (ReceiptDate = 0D) or (CutoffDate = 0D) then
            Error(PlanningDatesErr);
        RequisitionLine.Get(TemplateName, BatchName, LineNo);
        RequisitionLine.TestField(Type, RequisitionLine.Type::Item);
        RequisitionLine.TestField("Replenishment System", RequisitionLine."Replenishment System"::Purchase);
        RequisitionLine.TestField("Action Message", RequisitionLine."Action Message"::New);
        RequisitionLine.TestField("Accept Action Message", true);
        RequisitionLine.TestField("Demand Type", Database::"Sales Line");
        RequisitionLine.TestField("Demand Order No.");
        RequisitionLine.TestField("Vendor No.");
        RequisitionLine.SetRecFilter();

        PurchaseHeaderDefaults."Order Date" := OrderDate;
        PurchaseHeaderDefaults."Posting Date" := PostingDate;
        PurchaseHeaderDefaults."Expected Receipt Date" := ReceiptDate;
        ReqWkshMakeOrder.Set(PurchaseHeaderDefaults, CutoffDate, false);
        ReqWkshMakeOrder.SetSuppressCommit(true);
        ReqWkshMakeOrder.CarryOutBatchAction(RequisitionLine);
    end;

    var
        PlanningDatesErr: Label 'Supply explicit order, posting, receipt, and cutoff dates.';
}
