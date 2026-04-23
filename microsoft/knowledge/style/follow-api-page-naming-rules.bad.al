page 51103 "Style Sample ApiPage Bad"
{
    PageType = API;
    APIPublisher = 'Contoso-App';   // hyphen not allowed
    APIGroup = 'app_1';              // underscore not allowed
    APIVersion = 'v2';               // missing minor version
    EntityName = 'customers';        // should be singular
    EntitySetName = 'customer';      // should be plural
    SourceTable = Customer;
    // DelayedInsert omitted; composite-key inserts misbehave

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(number; Rec."No.") { }
            }
        }
    }
}
