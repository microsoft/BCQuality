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

pageextension 50377 "Customer App Area Bad" extends "Customer Card"
{
    layout
    {
        addlast(General)
        {
            // Extension controls do not inherit ApplicationArea from the base page.
            field("Language Code Sample"; Rec."Language Code")
            {
                ToolTip = 'Specifies the language used for the customer.';
            }
        }
    }
}
