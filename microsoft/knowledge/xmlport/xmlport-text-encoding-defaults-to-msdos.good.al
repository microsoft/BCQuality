xmlport 50330 "Sample Customer Export Good"
{
    Caption = 'Sample Customer Export';
    Direction = Export;
    Format = VariableText;
    TextEncoding = UTF8;
    FieldSeparator = ';';

    schema
    {
        textelement(Root)
        {
            tableelement(Customer; Customer)
            {
                fieldelement(No; Customer."No.") { }
                fieldelement(Name; Customer.Name) { }
                fieldelement(City; Customer.City) { }
            }
        }
    }
}
