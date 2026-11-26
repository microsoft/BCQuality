// Demonstration only. Shows the wrong pattern: a hidden filter group is left active and later overwritten.

page 50186 "Region Customers Bad"
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
    begin
        Rec.FilterGroup(2);
        Rec.SetRange("Territory Code", GetUserTerritory());
        // BAD: no FilterGroup(0) here. The record stays in group 2.
        ApplyDefaultView(Rec);
    end;

    local procedure ApplyDefaultView(var Customer: Record Customer)
    begin
        // This runs in group 2 and replaces the territory restriction instead of adding to it.
        Customer.SetFilter("Territory Code", '<>%1', '');
    end;

    local procedure GetUserTerritory(): Code[10]
    begin
        exit('NORTH');
    end;
}
