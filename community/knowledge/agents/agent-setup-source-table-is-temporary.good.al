page 50100 "Sales Review Agent Setup"
{
    PageType = ConfigurationDialog;
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

    trigger OnOpenPage()
    var
        SalesReviewAgentSetup: Record "Sales Review Agent Setup";
    begin
        if IsNullGuid(Rec."User Security ID") then
            exit;
        if SalesReviewAgentSetup.Get(Rec."User Security ID") then
            Rec := SalesReviewAgentSetup;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        AgentSetup: Codeunit "Agent Setup";
        AgentSetupBuffer: Record "Agent Setup Buffer";
    begin
        if CloseAction = CloseAction::Cancel then
            exit(true);
        CurrPage.AgentSetupPart.Page.GetAgentSetupBuffer(AgentSetupBuffer);
        if AgentSetup.GetChangesMade(AgentSetupBuffer) then
            Rec."User Security ID" := AgentSetup.SaveChanges(AgentSetupBuffer);
        if IsNullGuid(Rec."User Security ID") then
            exit(true);
        SaveCustomProperties();
        exit(true);
    end;

    local procedure SaveCustomProperties()
    var
        SalesReviewAgentSetup: Record "Sales Review Agent Setup";
    begin
        if not SalesReviewAgentSetup.Get(Rec."User Security ID") then begin
            SalesReviewAgentSetup.Init();
            SalesReviewAgentSetup."User Security ID" := Rec."User Security ID";
            SalesReviewAgentSetup.Insert(true);
        end;
        SalesReviewAgentSetup."Review Threshold" := Rec."Review Threshold";
        SalesReviewAgentSetup.Modify(true);
    end;
}
