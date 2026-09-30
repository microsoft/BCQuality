table 50602 "Sample Order Header Good"
{
    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(2; "Document Date"; Date)
        {
            DataClassification = CustomerContent;
        }
    }

    trigger OnInsert()
    var
        SalesSetup: Record "Sales & Receivables Setup";
        NoSeries: Codeunit "No. Series";
    begin
        if "No." = '' then begin
            SalesSetup.Get();
            SalesSetup.TestField("Order Nos.");
            "No." := NoSeries.GetNextNo(SalesSetup."Order Nos.");
        end;

        InitRecord();
    end;

    procedure InitRecord()
    begin
        OnBeforeInitRecord(Rec);
        "Document Date" := WorkDate();
        OnAfterInitRecord(Rec);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitRecord(var SampleOrderHeader: Record "Sample Order Header Good")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitRecord(var SampleOrderHeader: Record "Sample Order Header Good")
    begin
    end;
}
