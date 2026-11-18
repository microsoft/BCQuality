page 50343 "Sample Wizard Footer Bad"
{
    PageType = NavigatePage;
    Caption = 'Set Up Customer Loyalty';

    layout
    {
        area(Content)
        {
            group(Welcome)
            {
                Caption = 'Welcome';
                InstructionalText = 'Use this guide to set up customer loyalty.';
                Visible = Step = Step::Welcome;
            }
            group(Done)
            {
                Caption = 'That''s it!';
                InstructionalText = 'Choose Finish to save the setup.';
                Visible = Step = Step::Done;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            // No InFooterBar: the actions are not added to the wizard footer.
            action(Back)
            {
                ApplicationArea = All;
                Caption = '&Back';
                Image = Undo;

                trigger OnAction()
                begin
                    Step := Step::Welcome;
                end;
            }
            action(Next)
            {
                ApplicationArea = All;
                Caption = '&Next';
                Image = Start;

                trigger OnAction()
                begin
                    Step := Step::Done;
                end;
            }
            action(Finish)
            {
                ApplicationArea = All;
                Caption = '&Finish';
                Image = Save;

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        Step: Option Welcome,Done;
}
