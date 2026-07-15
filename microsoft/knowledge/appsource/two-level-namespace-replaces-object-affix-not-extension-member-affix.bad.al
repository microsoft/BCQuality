namespace Contoso;

table 50462 "Rental Agreement"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20]) { }
    }
}

tableextension 50463 "Rental Customer Ext" extends Customer
{
    fields
    {
        field(50463; "Loyalty Points"; Integer)
        {
            DataClassification = CustomerContent;
        }
    }
}
