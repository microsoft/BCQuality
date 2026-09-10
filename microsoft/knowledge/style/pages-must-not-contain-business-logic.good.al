codeunit 50100 "Sales Line Management"
{
    procedure RecalculateLine(var SalesLine: Record "Sales Line")
    begin
        SalesLine."Total Amount" := SalesLine.Quantity * SalesLine."Unit Price";
        SalesLine.Modify();
    end;
}

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
                    SalesLineMgt.RecalculateLine(Rec);
                end;
            }
        }
    }

    var
        SalesLineMgt: Codeunit "Sales Line Management";
}
