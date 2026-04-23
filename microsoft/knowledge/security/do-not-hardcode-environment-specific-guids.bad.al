codeunit 51301 "Sec Sample EnvGuid Bad"
{
    procedure GetTenantId(): Text
    begin
        // Tenant GUID hardcoded. Extension works in one environment, fails in every other.
        exit('{12345678-1234-1234-1234-123456789012}');
    end;

    procedure GetAadApplicationId(): Text
    begin
        // AAD application GUID hardcoded. Same problem, surfaces as an authentication error.
        exit('{87654321-4321-4321-4321-210987654321}');
    end;
}
