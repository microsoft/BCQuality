tableextension 50223 "Sec Sample VTR Good" extends Customer
{
    fields
    {
        field(50223; "External Customer Ref"; Code[50])
        {
            TableRelation = Customer."No.";
            ValidateTableRelation = false;
            TestTableRelation = false;

            trigger OnValidate()
            var
                InvalidExternalReferenceErr: Label 'The external customer reference must not contain spaces.';
            begin
                "External Customer Ref" := CopyStr(
                    UpperCase(DelChr("External Customer Ref", '<>', ' ')),
                    1, MaxStrLen("External Customer Ref"));
                if StrPos("External Customer Ref", ' ') > 0 then
                    Error(InvalidExternalReferenceErr);
            end;
        }
    }
}
