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
        CustomerNo: Code[20];
        IsInitialized: Boolean;

    local procedure InitTest()
    var
        Customer: Record Customer;
    begin
        // Do not assume a customer already exists: a BCPT run may target an
        // otherwise-empty environment. Create one if none is found instead
        // of failing on FindFirst().
        if not Customer.FindFirst() then begin
            Customer.Init();
            Customer."No." := GenerateUniqueCode(MaxStrLen(Customer."No."));
            Customer.Insert(true);
        end;
        CustomerNo := Customer."No.";
    end;

    local procedure GenerateUniqueCode(Length: Integer): Code[20]
    begin
        // A GUID-derived code, not a session-local counter: it stays unique
        // across concurrent BCPT sessions and repeated runs against the
        // same environment, which an in-memory counter reset per session
        // cannot guarantee.
        exit(CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, Length));
    end;

    local procedure CreateServiceRequest(var BCPTTestContext: Codeunit "BCPT Test Context")
    var
        ServiceRequestHeader: Record "Service Request Header";
        ServiceRequestLine: Record "Service Request Line";
    begin
        BCPTTestContext.StartScenario('Create Service Request Header');
        ServiceRequestHeader.Init();
        ServiceRequestHeader."No." := GenerateUniqueCode(MaxStrLen(ServiceRequestHeader."No."));
        ServiceRequestHeader.Validate("Customer No.", CustomerNo);
        ServiceRequestHeader.Insert(true);
        BCPTTestContext.EndScenario('Create Service Request Header');
        BCPTTestContext.UserWait();

        BCPTTestContext.StartScenario('Add Service Request Line');
        ServiceRequestLine.Init();
        ServiceRequestLine."Document No." := ServiceRequestHeader."No.";
        ServiceRequestLine."Line No." := 10000;
        ServiceRequestLine.Description := 'Performance test line';
        ServiceRequestLine.Insert(true);
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
