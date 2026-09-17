codeunit 50100 "Sales Review Agent Instr."
{
    procedure GetInstructions() Instructions: SecretText
    var
        Builder: TextBuilder;
    begin
        Builder.AppendLine('# Responsibilities');
        Builder.AppendLine('You validate sales orders against customer credit and hold status.');
        Builder.AppendLine('# Guidelines');
        Builder.AppendLine('Always request a review before posting or sending external mail.');
        Builder.AppendLine('# Instructions');
        Builder.AppendLine('1. Open the sales order named in the task.');
        Builder.AppendLine('2. Check credit limit and overdue balance.');
        Builder.AppendLine('3. Document the result on the order and request a review.');
        Instructions := Builder.ToText();
    end;
}
