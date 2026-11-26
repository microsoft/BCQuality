page 50342 "Sample Wizard Footer Good"
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
            action(Back)
            {
                ApplicationArea = All;
                Caption = '&Back';
                Enabled = Step <> Step::Welcome;
                InFooterBar = true;
                Image = PreviousRecord;

                trigger OnAction()
                begin
                    Step := Step::Welcome;
                end;
            }
            action(Next)
            {
                ApplicationArea = All;
                Caption = '&Next';
                Enabled = Step <> Step::Done;
                InFooterBar = true;
                Image = NextRecord;

                trigger OnAction()
                begin
                    Step := Step::Done;
                end;
            }
            action(Finish)
            {
                ApplicationArea = All;
                Caption = '&Finish';
                Enabled = Step = Step::Done;
                InFooterBar = true;
                Image = Approve;

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
