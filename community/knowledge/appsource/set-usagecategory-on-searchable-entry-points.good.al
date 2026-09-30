page 50100 "Rental Agreement List"
{
    PageType = List;
    SourceTable = "Rental Agreement";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Agreements)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}