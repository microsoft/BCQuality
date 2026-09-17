codeunit 50100 "Sales Review Agent Instr."
{
    procedure GetInstructions() Instructions: SecretText
    var
        PromptLbl: Label 'Check customer credit for the given sales order. Document the result.', Locked = true;
    begin
        Instructions := PromptLbl;
    end;
}
