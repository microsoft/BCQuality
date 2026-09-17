page 50100 "Sales Review Agent Setup"
{
    PageType = ConfigurationDialog;
    Caption = 'Set up Sales Review Agent';
    SourceTable = "Sales Review Agent Setup";
    SourceTableTemporary = true;
    Extensible = false;

    layout
    {
        area(Content)
        {
            part(AgentSetupPart; "Agent Setup Part")
            {
                ApplicationArea = All;
                UpdatePropagation = Both;
            }
            group(AdditionalConfiguration)
            {
                Caption = 'Additional Configuration';
                field(ReviewThreshold; Rec."Review Threshold")
                {
                    ApplicationArea = All;
                    Caption = 'Review Threshold';
                    ToolTip = 'Specifies the threshold used when the agent requests a review.';
                }
            }
        }
    }
}
