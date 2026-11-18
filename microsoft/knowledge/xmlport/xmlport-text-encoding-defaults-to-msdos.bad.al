xmlport 50331 "Sample Customer Export Bad"
{
    Caption = 'Sample Customer Export';
    Direction = Export;
    Format = VariableText;
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
