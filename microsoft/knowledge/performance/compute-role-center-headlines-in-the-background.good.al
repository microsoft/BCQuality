table 50600 "Top Invoice Headline"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "User Security ID"; Guid) { }
        field(2; "Headline Text"; Text[250]) { }
        field(3; "Headline Visible"; Boolean) { }
    }

    keys
    {
        key(PK; "User Security ID") { Clustered = true; }
    }
}

codeunit 50600 "Top Invoice Headline Mgt."
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"RC Headlines Executor", 'OnComputeHeadlines', '', false, false)]
    local procedure ComputeOnComputeHeadlines(RoleCenterPageID: Integer)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        TopInvoiceHeadline: Record "Top Invoice Headline";
        TopAmount: Decimal;
    begin
        if RoleCenterPageID <> Page::"Headline RC Order Processor" then
            exit;
        if not TopInvoiceHeadline.WritePermission() then
            exit;

        CustLedgerEntry.SetCurrentKey("Document Type", "Posting Date");
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange("Posting Date", CalcDate('<-30D>', WorkDate()), WorkDate());
        CustLedgerEntry.SetLoadFields("Sales (LCY)");
        if CustLedgerEntry.FindSet() then
            repeat
                if CustLedgerEntry."Sales (LCY)" > TopAmount then
                    TopAmount := CustLedgerEntry."Sales (LCY)";
            until CustLedgerEntry.Next() = 0;

        if not TopInvoiceHeadline.Get(UserSecurityId()) then begin
            TopInvoiceHeadline."User Security ID" := UserSecurityId();
            TopInvoiceHeadline.Insert();
        end;
        TopInvoiceHeadline."Headline Visible" := TopAmount > 0;
        TopInvoiceHeadline."Headline Text" := StrSubstNo(TopInvoiceTxt, TopAmount);
        TopInvoiceHeadline.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"RC Headlines Page Common", 'OnIsAnyExtensionHeadlineVisible', '', false, false)]
    local procedure ReportVisibility(var ExtensionHeadlinesVisible: Boolean; RoleCenterPageID: Integer)
    var
        Visible: Boolean;
        HeadlineText: Text[250];
    begin
        if RoleCenterPageID <> Page::"Headline RC Order Processor" then
            exit;
        GetStoredHeadline(Visible, HeadlineText);
        if Visible then
            ExtensionHeadlinesVisible := true;
    end;

    procedure GetStoredHeadline(var Visible: Boolean; var HeadlineText: Text[250])
    var
        TopInvoiceHeadline: Record "Top Invoice Headline";
    begin
        Visible := false;
        if TopInvoiceHeadline.Get(UserSecurityId()) then begin
            Visible := TopInvoiceHeadline."Headline Visible";
            HeadlineText := TopInvoiceHeadline."Headline Text";
        end;
    end;

    var
        TopInvoiceTxt: Label '<qualifier>Last 30 days</qualifier><payload>Your largest invoice was <emphasize>%1</emphasize></payload>', Comment = '%1 = amount';
}

pageextension 50600 "Top Invoice Headline" extends "Headline RC Order Processor"
{
    layout
    {
        addlast(Content)
        {
            group(TopInvoice)
            {
                ShowCaption = false;
                Visible = TopInvoiceVisible;

                field(TopInvoiceText; TopInvoiceText)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Top invoice headline';
                    Editable = false;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        TopInvoiceHeadlineMgt: Codeunit "Top Invoice Headline Mgt.";
    begin
        TopInvoiceHeadlineMgt.GetStoredHeadline(TopInvoiceVisible, TopInvoiceText);
    end;

    var
        TopInvoiceVisible: Boolean;
        TopInvoiceText: Text[250];
}
