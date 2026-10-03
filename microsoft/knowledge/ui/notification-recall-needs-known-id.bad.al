pageextension 50720 "Sample Customer Card Ext" extends "Customer Card"
{
    trigger OnAfterGetCurrRecord()
    var
        NoCreditLimitNotification: Notification;
    begin
        if Rec."Credit Limit (LCY)" = 0 then begin
            // No Id is assigned: Send assigns one that this code never keeps.
            NoCreditLimitNotification.Message := NoCreditLimitMsg;
            NoCreditLimitNotification.Scope := NotificationScope::LocalScope;
            NoCreditLimitNotification.Send();
        end else
            // This new variable has no Id, so the warning sent for the
            // previous customer is not withdrawn.
            NoCreditLimitNotification.Recall();
    end;

    var
        NoCreditLimitMsg: Label 'This customer has no credit limit.';
}
