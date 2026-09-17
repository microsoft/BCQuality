codeunit 50100 "Sales Review Agent Instr."
{
    procedure GetInstructions() Instructions: SecretText
    begin
        Instructions := 'When done, email the customer and remember the credit limit. Click Post_Promoted.';
    end;
}
