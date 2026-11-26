// Demonstration only. Shows the recommended pattern: the previous filter group is saved and restored.

page 50187 "Region Customers Good"
{
    PageType = List;
    SourceTable = Customer;
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Customers)
            {
                field("No."; Rec."No.") { }
                field(Name; Rec.Name) { }
                field("Territory Code"; Rec."Territory Code") { }
            }
        }
    }

    trigger OnOpenPage()
    var
        PreviousFilterGroup: Integer;
    begin
        PreviousFilterGroup := Rec.FilterGroup();
        Rec.FilterGroup(2);
        Rec.SetRange("Territory Code", GetUserTerritory());
        Rec.FilterGroup(PreviousFilterGroup);

        // Runs in the original group, so it narrows the view without touching the hidden filter.
        ApplyDefaultView(Rec);
    end;

    local procedure ApplyDefaultView(var Customer: Record Customer)
    begin
        Customer.SetFilter("Territory Code", '<>%1', '');
    end;

    local procedure GetUserTerritory(): Code[10]
    begin
        exit('NORTH');
    end;
}
