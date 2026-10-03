pageextension 50720 "Sample Customer Card Ext" extends "Customer Card"
{
    trigger OnAfterGetCurrRecord()
    var
        NoCreditLimitNotification: Notification;
    begin
        // A fixed Id lets this code recall the notification it sent earlier.
        NoCreditLimitNotification.Id := GetNoCreditLimitNotificationId();
        NoCreditLimitNotification.Recall();
        if Rec."Credit Limit (LCY)" = 0 then begin
            NoCreditLimitNotification.Message := NoCreditLimitMsg;
            NoCreditLimitNotification.Scope := NotificationScope::LocalScope;
            NoCreditLimitNotification.Send();
        end;
    end;

    local procedure GetNoCreditLimitNotificationId(): Guid
    begin
        exit('6f0c2b8e-4a1d-4f7e-9b3a-2d5e8c1f7a40');
    end;

    var
        NoCreditLimitMsg: Label 'This customer has no credit limit.';
}
