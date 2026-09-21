codeunit 50543 "Test Sample Posted Fixture Bad"
{
    Subtype = Test;
    TestPermissions = Disabled; // does not help: the check is the license, not the permission set

    // Direct insert into a posted table: green under a container runner,
    // "Your license does not grant you ... Insert" under a SaaS user license.
    local procedure CreatePostedPurchaseInvoice(): Code[20]
    var
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        PurchInvHeader.Init();
        PurchInvHeader."No." := 'PI-TEST-001';
        PurchInvHeader.Insert();
        exit(PurchInvHeader."No.");
    end;

    [Test]
    procedure PostedInvoiceIsAvailable()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        PurchInvHeader.Get(CreatePostedPurchaseInvoice());
    end;
}
