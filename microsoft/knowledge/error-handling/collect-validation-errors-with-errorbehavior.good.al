codeunit 50185 "Collect Errors Good Sample"
{
    [ErrorBehavior(ErrorBehavior::Collect)]
    procedure ValidateAllItems()
    var
        Item: Record Item;
        CollectedErrors: List of [ErrorInfo];
        CollectedError: ErrorInfo;
        ErrorText: Text;
    begin
        if Item.FindSet() then
            repeat
                // Run each item in its own context so one failure does not abandon the rest.
                Codeunit.Run(Codeunit::"Collect Errors Item Check", Item);
            until Item.Next() = 0;

        if HasCollectedErrors() then begin
            CollectedErrors := GetCollectedErrors();
            foreach CollectedError in CollectedErrors do
                ErrorText += CollectedError.Message() + '\';
            Message('The following must be fixed before posting:\%1', ErrorText);
        end;
    end;
}

codeunit 50186 "Collect Errors Item Check"
{
    TableNo = Item;

    trigger OnRun()
    begin
        if Rec.Description = '' then
            Error('Item %1 has no description.', Rec."No.");
        if Rec."Unit Cost" <= 0 then
            Error('Item %1 must have a positive unit cost.', Rec."No.");
    end;
}
