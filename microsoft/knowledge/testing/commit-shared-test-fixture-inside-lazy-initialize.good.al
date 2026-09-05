codeunit 50142 "Sample Test Library"
{
    var
        Initialized: Boolean;

    procedure Initialize()
    begin
        if Initialized then
            exit;

        CreateSharedFixtureData();
        Commit();
        Initialized := true;
    end;

    local procedure CreateSharedFixtureData()
    begin
        // insert master/setup data shared across every test in this codeunit
    end;
}
