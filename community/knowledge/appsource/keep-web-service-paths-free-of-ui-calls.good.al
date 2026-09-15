codeunit 50100 "Rental Service"
{
    [ServiceEnabled]
    procedure CloseAgreement(AgreementNo: Code[20]): Boolean
    var
        RentalAgreement: Record "Rental Agreement";
    begin
        if not RentalAgreement.Get(AgreementNo) then
            exit(false);

        RentalAgreement.Closed := true;
        RentalAgreement.Modify(true);
        exit(true);
    end;
}