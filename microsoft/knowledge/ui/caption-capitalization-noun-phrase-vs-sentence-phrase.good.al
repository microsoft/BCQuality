page 51000 "UI Sample Caption Good"
{
    PageType = List;
    SourceTable = Customer;

    // Noun-phrase page caption: Title Case.
    Caption = 'Sales Orders';

    actions
    {
        area(Processing)
        {
            // Sentence-phrase action caption: Sentence case.
            action(PostAndPrint)
            {
                Caption = 'Post and print';
                ApplicationArea = All;
            }

            action(SendEmail)
            {
                Caption = 'Send email';
                ApplicationArea = All;
            }
        }
    }
}
