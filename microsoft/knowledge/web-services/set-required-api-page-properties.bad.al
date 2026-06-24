// Malformed API endpoint: APIPublisher and APIGroup are missing, and there is
// no SourceTable. The page compiles but the route cannot be composed, so the
// entity is never published where an integration expects it.
page 50341 "WS Required Props Bad"
{
    PageType = API;
    APIVersion = 'v1.0';
    EntityName = 'customer';
    EntitySetName = 'customers';

    layout
    {
        area(content)
        {
            repeater(records)
            {
                field(displayName; Rec.Name)
                {
                    Caption = 'displayName';
                }
            }
        }
    }
}
