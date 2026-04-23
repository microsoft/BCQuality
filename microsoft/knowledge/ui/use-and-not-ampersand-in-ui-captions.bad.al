page 51007 "UI Sample Ampersand Bad"
{
    PageType = Card;
    SourceTable = "Sales Header";

    actions
    {
        area(Processing)
        {
            action(PostAndSend)
            {
                // '&' is being used as "and", not as an accelerator prefix. The
                // parser cannot tell; translators re-evaluate every occurrence.
                Caption = 'Post & Send';
                ApplicationArea = All;
                ToolTip = 'Post and send the document.';
            }
        }
    }
}
