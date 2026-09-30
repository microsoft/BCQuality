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
        // BUG: no Commit() here. The fixture below is still inside this
        // test method's own transaction.
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
        // The deliberate rollback above also erases the never-committed
        // fixture from CreateSharedFixtureData(). Initialized still reads
        // true on the next test, but the row it points at is gone.
    end;

    [Test]
    procedure SecondTestStillFindsSharedFixture()
    var
        Item: Record Item;
    begin
        Initialize();

        // Fails here: Initialize() saw Initialized = true and returned
        // immediately, so it never recreated the fixture - and the first
        // test's rollback took the original row with it.
        Item.Get(SharedItemNo);
    end;
}

codeunit 50143 "Sample Test Runner"
{
    // Codeunit isolation alone does not save this fixture: TestIsolation
    // only controls whether committed changes survive between methods, and
    // this fixture was never committed in the first place.
    Subtype = TestRunner;
    TestIsolation = Codeunit;

    trigger OnRun()
    begin
        Codeunit.Run(Codeunit::"Sample Test Library");
    end;
}
