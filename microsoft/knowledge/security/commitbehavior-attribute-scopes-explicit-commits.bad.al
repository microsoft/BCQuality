codeunit 50151 "Sec Sample CommitBeh Bad"
{
    [IntegrationEvent(true, false)]
    procedure OnBeforeApplyingDiscount(var Customer: Record Customer)
    begin
    end;

    procedure ApplyDiscount(var Customer: Record Customer)
    begin
        Customer."Customer Price Group" := 'VIP';
        Customer.Modify(true);
        OnBeforeApplyingDiscount(Customer);
        if Customer."Credit Limit (LCY)" <= 0 then
            Error('Customer %1 not eligible', Customer."No.");
        Commit();
    end;
}

codeunit 50152 "Sec Sample CommitBeh Bad Sub"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sec Sample CommitBeh Bad", 'OnBeforeApplyingDiscount', '', true, true)]
    local procedure NotifyOther(var Customer: Record Customer)
    begin
        Commit();
    end;
}
