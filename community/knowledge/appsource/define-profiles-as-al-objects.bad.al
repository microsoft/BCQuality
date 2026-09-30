codeunit 50100 "Rental Profile Install"
{
    Subtype = Install;

    trigger OnInstallAppPerDatabase()
    var
        RentalProfile: Record Profile;
    begin
        RentalProfile.Init();
        RentalProfile.Insert(true);
    end;
}