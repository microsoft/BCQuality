page 50100 "Rental Agreement List"
{
    PageType = List;
    SourceTable = "Rental Agreement";
    ApplicationArea = All;

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