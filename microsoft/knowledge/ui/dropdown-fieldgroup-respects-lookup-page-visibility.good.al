tableextension 50620 "Ship-to Dropdown Good" extends "Ship-to Address"
{
    fieldgroups
    {
        addlast(DropDown; "Address 2")
        {
        }
    }
}

pageextension 50621 "Ship-to Lookup Good" extends "Ship-to Address List"
{
    layout
    {
        modify("Address 2")
        {
            Visible = true;
        }
    }
}
