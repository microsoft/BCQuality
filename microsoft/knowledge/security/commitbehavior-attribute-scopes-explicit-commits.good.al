codeunit 50149 "Sec Sample CommitBeh Good"
{
    [CommitBehavior(CommitBehavior::Ignore)]
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

codeunit 50150 "Sec Sample CommitBeh Good Sub"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sec Sample CommitBeh Good", 'OnBeforeApplyingDiscount', '', true, true)]
    local procedure NotifyOther(var Customer: Record Customer)
    begin
        Commit();
    end;
}
