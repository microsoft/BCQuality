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
            // The default is false; true retrieves and clears the collection.
            CollectedErrors := GetCollectedErrors(true);
            // This blocking aggregate intentionally retains messages only.
            foreach CollectedError in CollectedErrors do
                ErrorText += CollectedError.Message() + '\';
            Error(ErrorInfo.Create(
                StrSubstNo('The following must be fixed before posting:\%1', ErrorText), false));
        end;
    end;
}

codeunit 50186 "Collect Errors Item Check"
{
    TableNo = Item;

    trigger OnRun()
    begin
        if Rec.Description = '' then
            Error(ErrorInfo.Create(
                StrSubstNo('Item %1 has no description.', Rec."No."), true));
        if Rec."Unit Cost" <= 0 then
            Error(ErrorInfo.Create(
                StrSubstNo('Item %1 must have a positive unit cost.', Rec."No."), true));
    end;
}
