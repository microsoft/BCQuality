page 50100 "Sales Line Card"
{
    PageType = Card;
    SourceTable = "Sales Line";

    actions
    {
        area(Processing)
        {
            action(Recalculate)
            {
                trigger OnAction()
                begin
                    Rec."Total Amount" := Rec.Quantity * Rec."Unit Price";
                    Rec.Modify();
                end;
            }
        }
    }
}
