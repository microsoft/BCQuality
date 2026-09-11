codeunit 50100 "Rental Audit"
{
    procedure SetCreatedAt(var RentalAgreement: Record "Rental Agreement")
    begin
        RentalAgreement."Created At" := CurrentDateTime();
    end;
}