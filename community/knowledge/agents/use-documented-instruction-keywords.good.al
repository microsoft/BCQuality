codeunit 50100 "Sales Review Agent Instr."
{
    procedure GetInstructions() Instructions: SecretText
    var
        Builder: TextBuilder;
    begin
        Builder.AppendLine('When the sales order is ready, request a review before posting.');
        Builder.AppendLine('If a field is missing, ask for assistance.');
        Builder.AppendLine('Memorize the customer credit limit for later steps.');
        Builder.AppendLine('When confirmed, write an email to the salesperson; outbound mail is reviewed.');
        Instructions := Builder.ToText();
    end;
}
