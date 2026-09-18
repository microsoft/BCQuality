codeunit 50641 "Sample Upgrade Part One"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        CreateUpgradeState();
    end;

    local procedure CreateUpgradeState()
    begin
    end;
}

codeunit 50642 "Sample Upgrade Part Two"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        // This can run before Part One; object IDs do not sequence upgrade codeunits.
        MigrateDataThatRequiresUpgradeState();
    end;

    local procedure MigrateDataThatRequiresUpgradeState()
    begin
    end;
}
