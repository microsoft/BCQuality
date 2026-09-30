codeunit 50142 "Sample Test Library"
{
    Subtype = Test;

    var
        LibraryInventory: Codeunit "Library - Inventory";
        Initialized: Boolean;
        SharedItemNo: Code[20];
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
    var
        Item: Record Item;
    begin
        LibraryInventory.CreateItem(Item);
        SharedItemNo := Item."No.";
    end;

    [Test]
    procedure FirstTestUsesSharedFixture()
    var
        Item: Record Item;
    begin
        Initialize();

        Item.Get(SharedItemNo);
        Item.Description := 'Scratch change this test makes and does not need to keep.';
        Item.Modify();

        asserterror Error(RollBackMsg);
        // Rolls back the Modify() above, but not the fixture: that was
        // already committed inside Initialize().
    end;

    [Test]
    procedure SecondTestStillFindsSharedFixture()
    var
        Item: Record Item;
    begin
        // Runs after FirstTestUsesSharedFixture's deliberate rollback.
        // Initialize() sees Initialized = true and does nothing, but the
        // committed fixture it created earlier is still there to Get().
        Initialize();

        Item.Get(SharedItemNo);
    end;
}

codeunit 50143 "Sample Test Runner"
{
    // Codeunit isolation: everything this codeunit's tests commit,
    // including the shared fixture, survives from one test method to the
    // next, and rolls back only once every method in the codeunit has run.
    Subtype = TestRunner;
    TestIsolation = Codeunit;

    trigger OnRun()
    begin
        Codeunit.Run(Codeunit::"Sample Test Library");
    end;
}
