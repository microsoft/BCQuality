page 50375 "Sample App Area Bad"
{
    PageType = Card;
    SourceTable = Customer;
    layout
    {
        area(Content)
        {
            group(General)
            {
                // Anti-pattern: no ApplicationArea. AS0062 flags this control,
                // and it is silently hidden in the Web client for profiles whose
                // enabled areas do not already cover it.
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the number that identifies the customer.';
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the customer''s name.';
                }
            }
        }
    }
}
