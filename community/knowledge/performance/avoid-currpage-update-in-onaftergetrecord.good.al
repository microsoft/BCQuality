page 50100 "CurrPage Update OAGR Good"
{
    PageType = List;
    SourceTable = Customer;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Rows)
            {
                field("No."; Rec."No.") { }
                field(Warning; WarningText) { }
            }
        }
    }

    var
        WarningText: Text[50];

    trigger OnAfterGetRecord()
    begin
        WarningText := CopyStr(Rec.Name, 1, MaxStrLen(WarningText));
    end;
}
