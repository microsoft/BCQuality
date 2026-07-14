codeunit 50411 "Test Library Fixtures Bad"
{
    Subtype = Test;

    [Test]
    procedure OrderUsesHandRolledFixtures()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
    begin
        // Hand-rolled customer: a chosen "No." with no number-series entry and
        // none of the mandatory fields a real customer carries. Bypasses the
        // setup production code assumes and breaks when the schema adds a
        // required field this test does not set.
        Customer.Init();
        Customer."No." := 'X';
        Customer.Insert();

        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := 'SO-X';
        SalesHeader.Validate("Sell-to Customer No.", Customer."No.");
        SalesHeader.Insert(true);
    end;
}
