page 50730 "Sample Open Sales Docs"
{
    PageType = List;
    SourceTable = "Sales Header";
    Editable = false;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    Caption = 'Sample Open Sales Documents';

    layout
    {
        area(Content)
        {
            repeater(Documents)
            {
                field("Document Type"; Rec."Document Type") { }
                field("No."; Rec."No.") { }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name") { }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ShowDocument)
            {
                Caption = 'Show Document';
                Image = EditLines;
                ShortCutKey = 'Return';
                ToolTip = 'Open the selected sales document.';

                trigger OnAction()
                var
                    PageManagement: Codeunit "Page Management";
                begin
                    // Page Management picks the page for each Document Type.
                    PageManagement.PageRun(Rec);
                end;
            }
        }
    }
}
