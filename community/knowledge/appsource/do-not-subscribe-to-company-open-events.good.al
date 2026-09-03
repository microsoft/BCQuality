codeunit 50100 "Rental Feature Setup"
{
    procedure EnsureInitialized()
    var
        RentalSetup: Record "Rental Setup";
    begin
        if RentalSetup.Get() then
            exit;

        RentalSetup.Init();
        RentalSetup.Insert(true);
    end;
}