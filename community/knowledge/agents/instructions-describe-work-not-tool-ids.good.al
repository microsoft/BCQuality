codeunit 50100 "Sales Review Agent Instr."
{
    procedure GetInstructions() Instructions: SecretText
    var
        Builder: TextBuilder;
    begin
        Builder.AppendLine('Memorize the sales order number from the task.');
        Builder.AppendLine('Set the order on hold when credit fails, with a reason.');
        Builder.AppendLine('When credit passes, request a review before posting the order.');
        Instructions := Builder.ToText();
    end;
}
