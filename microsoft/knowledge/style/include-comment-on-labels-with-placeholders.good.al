codeunit 51106 "Style Sample LabelProps Good"
{
    procedure Example()
    var
        CustomerNotFoundErr: Label 'Customer %1 does not exist for document %2.',
            Comment = '%1 = Customer No., %2 = Document No.';
        HttpsProtocolTok: Label 'HTTPS', Locked = true;
        ShortDescLbl: Label 'Description text', MaxLength = 50;
        CustomerNo: Code[20];
        DocumentNo: Code[20];
    begin
        Error(CustomerNotFoundErr, CustomerNo, DocumentNo);
    end;
}
