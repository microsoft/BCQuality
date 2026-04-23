codeunit 51107 "Style Sample LabelProps Bad"
{
    procedure Example()
    var
        // Two placeholders, no Comment. The translator has to guess which
        // identifier maps to %1 and which to %2.
        CustomerLocationErr: Label 'Customer %1 not found in %2.';
        // URL without Locked: enters the localization pipeline, may be translated.
        HttpsUrlLbl: Label 'https://example.com';
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        Error(CustomerLocationErr, CustomerNo, LocationCode);
    end;
}
