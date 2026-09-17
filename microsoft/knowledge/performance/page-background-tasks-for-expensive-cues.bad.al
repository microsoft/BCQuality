page 50100 "Cue Background Task Bad"
{
    PageType = CardPart;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            cuegroup(Group)
            {
                field(OpenOrders; OpenOrderCount)
                {
                    Caption = 'Open Sales Orders';
                }
            }
        }
    }

    var
        OpenOrderCount: Integer;

    trigger OnOpenPage()
    var
        SalesHeader: Record "Sales Header";
    begin
        // Blocks Role Center render on an exact count of sales headers.
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        OpenOrderCount := SalesHeader.Count();
    end;
}
