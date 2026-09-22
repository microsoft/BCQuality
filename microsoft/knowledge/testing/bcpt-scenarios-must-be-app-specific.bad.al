// Only wraps Microsoft's own generic scenario — measures BC, not this extension
codeunit 50101 "BCPT Create Sales Order" implements "BCPT Test Param. Provider"
{
    SingleInstance = true;

    trigger OnRun()
    begin
        CreateStandardSalesOrder(GlobalBCPTTestContext);
    end;

    var
        GlobalBCPTTestContext: Codeunit "BCPT Test Context";

    local procedure CreateStandardSalesOrder(var BCPTTestContext: Codeunit "BCPT Test Context")
    begin
        BCPTTestContext.StartScenario('Create Sales Order With N Lines');
        // ... standard sales order creation, no reference to the extension's own logic
        BCPTTestContext.EndScenario('Create Sales Order With N Lines');
    end;

    procedure GetDefaultParameters(): Text[1000]
    begin
        exit('');
    end;

    procedure ValidateParameters(Parameters: Text[1000])
    begin
    end;
}
