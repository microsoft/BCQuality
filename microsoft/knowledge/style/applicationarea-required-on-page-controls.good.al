page 50374 "Sample App Area Good"
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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number that identifies the customer.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
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
                ApplicationArea = All;
                ToolTip = 'Reloads the current record.';

                trigger OnAction()
                begin
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
