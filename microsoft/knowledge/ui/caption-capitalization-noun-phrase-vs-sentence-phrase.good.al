page 50210 "UI Sample Caption Case"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "Sales Line";

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the document number.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ShowSourceDocument)
            {
                Caption = 'Show source document';
                Image = ViewSourceDocumentLine;
                ToolTip = 'Open the related source document.';

                trigger OnAction()
                begin
                    Message('%1', Rec."Document No.");
                end;
            }
        }
    }
}
