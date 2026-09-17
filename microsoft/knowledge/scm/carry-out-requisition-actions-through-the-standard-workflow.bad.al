namespace BCQuality.SCM.Samples;

using Microsoft.Inventory.Requisition;
using Microsoft.Purchases.Document;
using Microsoft.Sales.Document;

codeunit 50116 "SCM Requisition Action Bad"
{
    procedure CarryOutAcceptedNewPurchase(TemplateName: Code[10]; BatchName: Code[10]; LineNo: Integer; OrderDate: Date; PostingDate: Date; ReceiptDate: Date; CutoffDate: Date)
    var
        RequisitionLine: Record "Requisition Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
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

        PurchaseHeader.Init();
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Order;
        PurchaseHeader.Insert(true);
        PurchaseHeader.Validate("Buy-from Vendor No.", RequisitionLine."Vendor No.");
        PurchaseHeader.Validate("Order Date", OrderDate);
        PurchaseHeader.Validate("Posting Date", PostingDate);
        PurchaseHeader.Validate("Expected Receipt Date", ReceiptDate);
        PurchaseHeader.Modify(true);

        PurchaseLine.Init();
        PurchaseLine."Document Type" := PurchaseHeader."Document Type";
        PurchaseLine."Document No." := PurchaseHeader."No.";
        PurchaseLine."Line No." := 10000;
        PurchaseLine.Validate(Type, PurchaseLine.Type::Item);
        PurchaseLine.Validate("No.", RequisitionLine."No.");
        PurchaseLine.Validate("Location Code", RequisitionLine."Location Code");
        PurchaseLine.Validate("Variant Code", RequisitionLine."Variant Code");
        PurchaseLine.Validate("Unit of Measure Code", RequisitionLine."Unit of Measure Code");
        PurchaseLine.Validate(Quantity, RequisitionLine.Quantity);
        PurchaseLine.Insert(true);

        RequisitionLine.Delete(true);
    end;

    var
        PlanningDatesErr: Label 'Supply explicit order, posting, receipt, and cutoff dates.';
}
