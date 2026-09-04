page 50102 "Vendor Contact Info API"
{
    PageType = API;
    APIPublisher = 'contoso';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    SourceTable = Vendor;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(GroupName)
            {
                field(no; Rec."No.") { Editable = false; }
                field(contactEmail; Rec."E-Mail") { }
            }
        }
    }
}
