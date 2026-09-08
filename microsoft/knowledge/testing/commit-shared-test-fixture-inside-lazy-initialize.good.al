codeunit 50142 "Sample Test Library"
{
    Subtype = Test;

    var
        Initialized: Boolean;
        RollBackMsg: Label 'Revert back the tables to their original state.';

    local procedure Initialize()
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

    [Test]
    procedure FirstTestUsesSharedFixture()
    begin
        Initialize();

        // exercise/verify against the shared fixture, then make scratch changes of its own

        asserterror Error(RollBackMsg);
    end;
}
