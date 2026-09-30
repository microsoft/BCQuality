codeunit 50100 "Rental Service"
{
    [ServiceEnabled]
    procedure CloseAgreement(AgreementNo: Code[20]): Boolean
    var
        RentalAgreement: Record "Rental Agreement";
    begin
        if not Confirm(CloseAgreementQst, false, AgreementNo) then
            exit(false);

        RentalAgreement.Get(AgreementNo);
        RentalAgreement.Closed := true;
        RentalAgreement.Modify(true);
        Message(AgreementClosedMsg, AgreementNo);
        exit(true);
    end;

    var
        CloseAgreementQst: Label 'Close rental agreement %1?';
        AgreementClosedMsg: Label 'Rental agreement %1 was closed.';
}