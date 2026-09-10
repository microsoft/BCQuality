page 50100 "Vendor Document API"
{
    PageType = API;
    APIPublisher = 'contoso';
    APIGroup = 'documents';
    APIVersion = 'v1.0';
    SourceTable = Vendor;
    // no InsertAllowed/ModifyAllowed override, no Editable = false anywhere

    layout
    {
        area(content)
        {
            repeater(GroupName)
            {
                field(no; Rec."No.") { }
                field(vatRegNo; Rec."VAT Registration No.") { }
                field(contactEmail; Rec."E-Mail") { }
                // ...dozens more fields, none marked Editable = false
            }
        }
    }
}
