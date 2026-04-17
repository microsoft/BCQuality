codeunit 50227 "Sec Sample SwallowErr Bad"
{
    procedure Authenticate(): Boolean
    begin
        if not TryAuthenticate() then
            exit(false);
        exit(true);
    end;

    [TryFunction]
    local procedure TryAuthenticate()
    begin
        // ...
    end;
}
