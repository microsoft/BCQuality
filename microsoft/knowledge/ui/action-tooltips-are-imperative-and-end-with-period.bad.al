page 51005 "UI Sample ActionTooltip Bad"
{
    PageType = Card;
    SourceTable = "Sales Header";

    actions
    {
        area(Processing)
        {
            action(Post)
            {
                Caption = 'Post';
                ApplicationArea = All;
                // Declarative, not imperative. No period.
                ToolTip = 'This will post the invoice';
            }
            action(SendForApproval)
            {
                Caption = 'Send for approval';
                ApplicationArea = All;
                // Fragment that repeats the caption and says nothing new.
                ToolTip = 'Send for approval';
            }
        }
    }
}
