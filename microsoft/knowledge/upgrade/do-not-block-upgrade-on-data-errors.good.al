codeunit 50206 "Upgrade Graceful"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpgradeCustomerLink('C00010');
    end;

    local procedure UpgradeCustomerLink(CustomerNo: Code[20])
    var
        Customer: Record Customer;
    begin
        if not Customer.Get(CustomerNo) then begin
            Session.LogMessage(
                'UPG0001',
                'Customer not found during upgrade',
                Verbosity::Warning,
                DataClassification::SystemMetadata,
                TelemetryScope::ExtensionPublisher,
                'CustomerNo', CustomerNo);
            exit;
        end;
        // Continue upgrade work using Customer ...
    end;
}
