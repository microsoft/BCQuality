codeunit 50201 "Upgrade My Feature"
{
    // This compiles, but no Subtype = Upgrade trigger wires it to the pipeline.
    procedure RunUpgrade()
    begin
        UpgradeMyFeature();
    end;

    local procedure UpgradeMyFeature() begin end;
}
