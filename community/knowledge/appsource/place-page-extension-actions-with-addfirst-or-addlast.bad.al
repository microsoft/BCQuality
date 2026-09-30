pageextension 50100 "Rental Customer List" extends "Customer List"
{
    actions
    {
        addafter("Customer Ledger Entries")
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