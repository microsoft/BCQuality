// Demonstration only. Shows the correct pattern: a public facade codeunit whose event publishers
// are internal, so only the implementation codeunit decides when they fire.

codeunit 50100 "Loyalty Points Mgt Good"
{
    procedure AwardPoints(CustomerNo: Code[20]; SalesAmount: Decimal)
    var
        LoyaltyPointsImpl: Codeunit "Loyalty Points Impl Good";
    begin
        LoyaltyPointsImpl.AwardPoints(CustomerNo, SalesAmount);
    end;

    // internal, not public: the implementation codeunit raises this and nobody else. Subscribers
    // bind through Codeunit::"Loyalty Points Mgt Good", which is public by default - that object
    // access is all a subscriber in another extension needs.
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeAwardPoints(CustomerNo: Code[20]; var Points: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterAwardPoints(CustomerNo: Code[20]; Points: Decimal)
    begin
    end;
}

codeunit 50101 "Loyalty Points Impl Good"
{
    Access = Internal;

    procedure AwardPoints(CustomerNo: Code[20]; SalesAmount: Decimal)
    var
        LoyaltyPointsMgt: Codeunit "Loyalty Points Mgt Good";
        Points: Decimal;
        IsHandled: Boolean;
    begin
        Points := SalesAmount / 10;

        IsHandled := false;
        LoyaltyPointsMgt.OnBeforeAwardPoints(CustomerNo, Points, IsHandled);
        if IsHandled then
            exit;

        // ... insert the loyalty entry ...

        LoyaltyPointsMgt.OnAfterAwardPoints(CustomerNo, Points);
    end;
}

codeunit 50102 "Loyalty Points Sub Good"
{
    // The shape a subscriber in a dependent extension takes: it names the public object, and is
    // indifferent to the publisher being internal.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Loyalty Points Mgt Good", 'OnAfterAwardPoints', '', false, false)]
    local procedure LogAwardedPointsOnAfterAwardPoints(CustomerNo: Code[20]; Points: Decimal)
    begin
        // ... write telemetry ...
    end;
}
