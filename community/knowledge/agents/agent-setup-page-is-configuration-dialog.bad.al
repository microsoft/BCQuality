page 50100 "Sales Review Agent Setup"
{
    PageType = Card;
    Caption = 'Set up Sales Review Agent';
    SourceTable = "Sales Review Agent Setup";

    layout
    {
        area(Content)
        {
            field(ReviewThreshold; Rec."Review Threshold")
            {
                ApplicationArea = All;
                Caption = 'Review Threshold';
                ToolTip = 'Specifies the threshold used when the agent requests a review.';
            }
        }
    }
}
