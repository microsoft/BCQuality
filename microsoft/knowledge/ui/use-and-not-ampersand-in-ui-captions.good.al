page 51006 "UI Sample Ampersand Good"
{
    PageType = Card;
    SourceTable = "Sales Header";

    actions
    {
        area(Processing)
        {
            action(PostAndSend)
            {
                // "and" written out. Ampersand-s marks 's' as the accelerator key.
                Caption = 'Post and &send';
                ApplicationArea = All;
                ToolTip = 'Post the document and send it to the customer.';
            }
        }
    }
}
