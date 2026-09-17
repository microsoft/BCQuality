// Demonstration only. Shows the wrong pattern: the publisher carries no access modifier, so it is
// public - which never was what lets extensions subscribe.

codeunit 50100 "Loyalty Points Mgt Bad"
{
    procedure AwardPoints(CustomerNo: Code[20]; SalesAmount: Decimal)
    var
        Points: Decimal;
        IsHandled: Boolean;
    begin
        Points := SalesAmount / 10;

        IsHandled := false;
        OnBeforeAwardPoints(CustomerNo, Points, IsHandled);
        if IsHandled then
            exit;

        // ... insert the loyalty entry ...
    end;

    // BAD: no access modifier, so this publisher is public. Public access does not enable
    // subscription - it enables raising. Narrowing it to internal after release breaks callers,
    // so the widening cannot be walked back cheaply.
    [IntegrationEvent(false, false)]
    procedure OnBeforeAwardPoints(CustomerNo: Code[20]; var Points: Decimal; var IsHandled: Boolean)
    begin
    end;
}

codeunit 50101 "Loyalty Points Caller Bad"
{
    procedure FirePublisherDirectly(CustomerNo: Code[20])
    var
        LoyaltyPointsMgt: Codeunit "Loyalty Points Mgt Bad";
        Points: Decimal;
        IsHandled: Boolean;
    begin
        // Compiles only because the publisher is public. Every subscriber runs although no points
        // were ever awarded, on a Points value nobody computed, and the IsHandled answer the
        // subscribers write is read by no one.
        LoyaltyPointsMgt.OnBeforeAwardPoints(CustomerNo, Points, IsHandled);
    end;
}
