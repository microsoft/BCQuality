codeunit 50100 "Rental Service"
{
    [ServiceEnabled]
    procedure CloseAgreement(AgreementNo: Code[20]): Boolean
    var
        RentalAgreement: Record "Rental Agreement";
    begin
        if not Confirm('Close rental agreement %1?', false, AgreementNo) then
            exit(false);

        RentalAgreement.Get(AgreementNo);
        RentalAgreement.Closed := true;
        RentalAgreement.Modify(true);
        Message('Rental agreement %1 was closed.', AgreementNo);
        exit(true);
    end;
}