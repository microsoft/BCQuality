page 51001 "UI Sample Caption Bad"
{
    PageType = List;
    SourceTable = Customer;

    // Noun phrase in Sentence case. Every other list page in the product is Title Case.
    Caption = 'Sales orders';

    actions
    {
        area(Processing)
        {
            // Sentence phrase in Title Case. Reads as a typo.
            action(PostAndPrint)
            {
                Caption = 'Post And Print';
                ApplicationArea = All;
            }
        }
    }
}
