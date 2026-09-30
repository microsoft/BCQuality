page 50630 "Sample Order Good"
{
    PageType = Document;
    SourceTable = "Sales Header";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total amount of the order.';
                }
            }
            part(Lines; "Sales Order Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Document Type" = field("Document Type"),
                              "Document No." = field("No.");
                UpdatePropagation = Both;
            }
        }
    }
}
