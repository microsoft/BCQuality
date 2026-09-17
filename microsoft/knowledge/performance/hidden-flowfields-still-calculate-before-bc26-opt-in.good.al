pageextension 50444 "Customer Balance Lazy" extends "Customer Card"
{
    layout
    {
        addlast(General)
        {
            field("Balance Preview"; BalancePreview)
            {
                ApplicationArea = All;
                Caption = 'Balance Preview';
                ToolTip = 'Specifies the balance when balance details are enabled.';
                Visible = ShowBalance;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        Clear(BalancePreview);
        if not ShowBalance then
            exit;
        Rec.CalcFields(Balance);
        BalancePreview := Rec.Balance;
    end;

    var
        BalancePreview: Decimal;
        ShowBalance: Boolean;
}
