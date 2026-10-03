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
                begin
                    // Copies the Sales Header mapping that Page Management
                    // already holds; Blanket Order and Return Order rows open nothing.
                    case Rec."Document Type" of
                        Rec."Document Type"::Quote:
                            Page.Run(Page::"Sales Quote", Rec);
                        Rec."Document Type"::Order:
                            Page.Run(Page::"Sales Order", Rec);
                        Rec."Document Type"::Invoice:
                            Page.Run(Page::"Sales Invoice", Rec);
                        Rec."Document Type"::"Credit Memo":
                            Page.Run(Page::"Sales Credit Memo", Rec);
                    end;
                end;
            }
        }
    }
}
