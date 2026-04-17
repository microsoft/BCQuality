codeunit 50137 "Perf Sample StrSubstNo Bad"
{
    procedure CustomerGreeting(var Customer: Record Customer): Text
    begin
        exit('Hello, ' + Customer.Name + ' (' + Customer."No." + ')');
    end;
}
