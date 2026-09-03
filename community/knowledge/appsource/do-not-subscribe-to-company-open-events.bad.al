codeunit 50100 "Rental Company Open"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", OnAfterCompanyOpen, '', false, false)]
    local procedure InitializeRentalSetup()
    var
        RentalSetup: Record "Rental Setup";
    begin
        if not RentalSetup.Get() then begin
            RentalSetup.Init();
            RentalSetup.Insert(true);
        end;
    end;
}