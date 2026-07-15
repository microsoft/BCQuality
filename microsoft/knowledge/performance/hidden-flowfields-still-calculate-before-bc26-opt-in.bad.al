pageextension 50445 "Customer Balance Hidden" extends "Customer Card"
{
    layout
    {
        addlast(General)
        {
            field(Balance; Rec.Balance)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the customer balance.';
                Visible = ShowBalance;
            }
        }
    }

    var
        ShowBalance: Boolean;
}
