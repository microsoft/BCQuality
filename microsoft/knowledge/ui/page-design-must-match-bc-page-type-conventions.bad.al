page 50131 "Sample Item List"
{
    PageType = List;
    SourceTable = "Sample Item";
    // Anti-pattern: no CardPageID even though a Card page exists for
    // this table, and no UsageCategory, so the page is invisible to
    // Tell Me search.
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Description; Rec.Description) { }
                field("No."; Rec."No.") { } // primary key buried, not left-most
            }
        }
    }
}
