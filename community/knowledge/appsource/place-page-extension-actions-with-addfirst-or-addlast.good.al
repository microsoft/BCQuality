pageextension 50100 "Rental Customer List" extends "Customer List"
{
    actions
    {
        addlast(Processing)
        {
            action(OpenRentalAgreements)
            {
                ApplicationArea = All;
                Caption = 'Rental Agreements';
                RunObject = page "Rental Agreement List";
            }
        }
    }
}