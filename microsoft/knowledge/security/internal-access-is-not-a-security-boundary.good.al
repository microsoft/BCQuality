table 50468 "Sensitive Setup"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10]) { }
    }
}

codeunit 50469 "Setup Authorization"
{
    procedure CanManageSetup(): Boolean
    var
        SensitiveSetup: Record "Sensitive Setup";
    begin
        exit(SensitiveSetup.WritePermission());
    end;
}

codeunit 50470 "Protected Setup Action"
{
    Access = Internal;

    trigger OnRun()
    begin
        if not SetupAuthorization.CanManageSetup() then
            Error(NotAuthorizedErr);
        UpdateSensitiveSetup();
    end;

    local procedure UpdateSensitiveSetup()
    begin
    end;

    var
        SetupAuthorization: Codeunit "Setup Authorization";
        NotAuthorizedErr: Label 'You are not authorized to manage this setup.';
}
