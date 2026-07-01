codeunit 50403 "Test Table Relation Bad"
{
    Subtype = Test;

    [Test]
    procedure SalesLineAcceptsExistingItem()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");

        // No item was created. Validating "No." against a non-existent item
        // raises a TableRelation error here, aborting the test at runtime
        // before any assertion runs.
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := 10000;
        SalesLine.Type := SalesLine.Type::Item;
        SalesLine.Validate("No.", 'GHOST');
        SalesLine.Insert(true);

        Assert.AreEqual('GHOST', SalesLine."No.", 'Unreachable: validation already failed.');
    end;

    var
        Assert: Codeunit "Library Assert";
        LibrarySales: Codeunit "Library - Sales";
}
