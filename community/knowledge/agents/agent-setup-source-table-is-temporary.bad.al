page 50100 "Sales Review Agent Setup"
{
    PageType = ConfigurationDialog;
    SourceTable = "Sales Review Agent Setup";

    layout
    {
        area(Content)
        {
            field(ReviewThreshold; Rec."Review Threshold")
            {
                ApplicationArea = All;
                Caption = 'Review Threshold';
                ToolTip = 'Specifies the threshold used when the agent requests a review.';

                trigger OnValidate()
                begin
                    Rec.Modify(true);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if Rec.IsEmpty() then
            Rec.Insert(true);
    end;
}
