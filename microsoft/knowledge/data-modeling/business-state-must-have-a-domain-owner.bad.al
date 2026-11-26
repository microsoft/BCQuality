tableextension 50100 "Sample Contact Customer" extends Customer
{
    fields
    {
        field(50100; "Sample Open Contact Issue"; Boolean)
        {
            Caption = 'Unresolved contact issue';
            FieldClass = FlowField;
            CalcFormula = exist("Job Queue Entry" where("Sample Account Id" = field(SystemId),
                                                       "Sample Open Contact Issue" = const(true)));
            Editable = false;
        }
    }
}

tableextension 50101 "Sample Contact Job" extends "Job Queue Entry"
{
    fields
    {
        field(50100; "Sample Account Id"; Guid)
        {
            DataClassification = CustomerContent;
        }
        field(50101; "Sample Open Contact Issue"; Boolean)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(SampleContact; "Sample Account Id", "Sample Open Contact Issue") { }
    }
}

codeunit 50100 "Sample Contact Inspection"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        Customer: Record Customer;
    begin
        Rec.TestField("Recurring Job", false);
        Rec.TestField("Manual Recurrence", false);
        Rec.TestField("Sample Account Id");
        Customer.GetBySystemId(Rec."Sample Account Id");
        if Customer."E-Mail" <> '' then
            exit;

        Rec."Sample Open Contact Issue" := true;
        Rec.Modify();
    end;

    procedure HasOpenContactIssue(CustomerNo: Code[20]): Boolean
    var
        Customer: Record Customer;
    begin
        Customer.Get(CustomerNo);
        Customer.CalcFields("Sample Open Contact Issue");
        exit(Customer."Sample Open Contact Issue");
    end;

    procedure ResolveContactIssue(CustomerNo: Code[20]; Email: Text[80])
    var
        Customer: Record Customer;
    begin
        Customer.Get(CustomerNo);
        Customer.Validate("E-Mail", Email);
        Customer.TestField("E-Mail");
        Customer.Modify(true);
    end;
}
