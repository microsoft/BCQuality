codeunit 50100 "BCPT Create Service Request" implements "BCPT Test Param. Provider"
{
    SingleInstance = true;

    trigger OnRun()
    begin
        if not IsInitialized then begin
            InitTest();
            IsInitialized := true;
        end;
        CreateServiceRequest(GlobalBCPTTestContext);
    end;

    var
        GlobalBCPTTestContext: Codeunit "BCPT Test Context";
        IsInitialized: Boolean;

    local procedure InitTest()
    begin
        // Set up any required configuration
    end;

    local procedure CreateServiceRequest(var BCPTTestContext: Codeunit "BCPT Test Context")
    begin
        BCPTTestContext.StartScenario('Create Service Request Header');
        // ... create the service request
        BCPTTestContext.EndScenario('Create Service Request Header');
        BCPTTestContext.UserWait();

        BCPTTestContext.StartScenario('Add Service Request Line');
        // ... add a line
        BCPTTestContext.EndScenario('Add Service Request Line');
    end;

    procedure GetDefaultParameters(): Text[1000]
    begin
        exit('');
    end;

    procedure ValidateParameters(Parameters: Text[1000])
    begin
    end;
}
