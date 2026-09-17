codeunit 50100 "Sales Review Agent Instr."
{
    procedure GetInstructions() Instructions: SecretText
    begin
        Instructions := 'Open page 42. Invoke action Post_Promoted. Use tool SalesOrder.CreditCheck_v3.';
    end;
}
