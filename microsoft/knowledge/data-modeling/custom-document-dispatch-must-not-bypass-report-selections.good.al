codeunit 50102 "Sample Settlement Document Send"
{
    procedure SendSettlementDocument(var Customer: Record Customer)
    var
        ReportSelections: Record "Report Selections";
    begin
        // Custom validation specific to this document stays here...
        CheckReadyToSend(Customer);

        // ...but dispatch goes through the registered usage, so per-account
        // report/layout overrides and email attachment/body configuration
        // on Report Selections all apply automatically.
        ReportSelections.SendEmailToCust(
            "Report Selection Usage"::"S.Invoice".AsInteger(), Customer, Customer."No.",
            Customer.Name, true, Customer."No.");
    end;

    local procedure CheckReadyToSend(var Customer: Record Customer)
    begin
        Customer.TestField("E-Mail");
    end;
}
