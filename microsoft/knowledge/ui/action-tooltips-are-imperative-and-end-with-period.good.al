page 51004 "UI Sample ActionTooltip Good"
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
                // Imperative verb-first sentence, Sentence case, terminating period.
                ToolTip = 'Post the current sales invoice and finalize the transaction.';
            }
            action(SendForApproval)
            {
                Caption = 'Send for approval';
                ApplicationArea = All;
                ToolTip = 'Send the document to the approval workflow.';
            }
        }
    }
}
