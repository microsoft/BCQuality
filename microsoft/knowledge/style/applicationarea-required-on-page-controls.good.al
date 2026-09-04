page 50374 "Sample App Area Good"
{
    PageType = Card;
    SourceTable = Customer;
    ApplicationArea = All;

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
    actions
    {
        area(Processing)
        {
            action(Refresh)
            {
                ToolTip = 'Reloads the current record.';

                trigger OnAction()
                begin
                    CurrPage.Update(false);
                end;
            }
        }
    }
}

pageextension 50376 "Customer App Area Good" extends "Customer Card"
{
    layout
    {
        addlast(General)
        {
            field("Language Code Sample"; Rec."Language Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the language used for the customer.';
            }
        }
    }
}
