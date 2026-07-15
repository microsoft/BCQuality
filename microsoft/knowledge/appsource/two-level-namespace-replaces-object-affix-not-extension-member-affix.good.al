namespace Contoso.Rentals;

table 50460 "Rental Agreement"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20]) { }
    }
}

tableextension 50461 "Rental Customer Ext" extends Customer
{
    fields
    {
        field(50461; "Loyalty Points RNT"; Integer)
        {
            DataClassification = CustomerContent;
        }
    }
}
