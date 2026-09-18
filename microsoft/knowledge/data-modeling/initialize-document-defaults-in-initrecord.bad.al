table 50603 "Sample Order Header Bad"
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
        "Document Date" := WorkDate();

        if "No." = '' then begin
            SalesSetup.Get();
            SalesSetup.TestField("Order Nos.");
            "No." := NoSeries.GetNextNo(SalesSetup."Order Nos.");
        end;
    end;
}
