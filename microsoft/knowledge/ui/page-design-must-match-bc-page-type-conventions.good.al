page 50130 "Sample Item List"
{
    PageType = List;
    SourceTable = "Sample Item";
    CardPageID = "Sample Item Card"; // links back to its Card page
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.") { } // primary key, left-most
                field(Description; Rec.Description) { }
            }
        }
    }
}
