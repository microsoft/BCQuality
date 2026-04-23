codeunit 51300 "Sec Sample EnvGuid Good"
{
    procedure KnownSystemId(): Guid
    begin
        // Stable across tenants and versions — Base Application Id.
        exit('{437dbf0e-84ff-417a-965d-ed2bb9650972}');
    end;

    procedure GetTenantId(): Text
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        // Environment-specific values are retrieved at runtime.
        exit(EnvironmentInformation.GetTenantId());
    end;
}
