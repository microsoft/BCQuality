codeunit 50136 "Perf Sample StrSubstNo Good"
{
    procedure CustomerGreeting(var Customer: Record Customer): Text
    var
        GreetingLbl: Label 'Hello, %1 (%2)';
    begin
        exit(StrSubstNo(GreetingLbl, Customer.Name, Customer."No."));
    end;
}
