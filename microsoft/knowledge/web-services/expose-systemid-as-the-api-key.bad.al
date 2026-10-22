// Unstable key: the endpoint addresses records by the business field "No.".
// When a user renames a customer's number, every external reference built on
// the old value dangles. ODataKeyFields should be SystemId instead.
page 50345 "WS SystemId Key Bad"
{
    PageType = API;
    APIPublisher = 'contoso';
    APIGroup = 'sales';
    APIVersion = 'v1.0';
    EntityName = 'customer';
    EntitySetName = 'customers';
    ODataKeyFields = "No.";
    SourceTable = Customer;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(records)
            {
                field(number; Rec."No.")
                {
                    Caption = 'number';
                }

                page 50347 "WS Configuration Key Bad"
                {
                    PageType = API;
                    APIPublisher = 'contoso';
                    APIGroup = 'configuration';
                    APIVersion = 'v1.0';
                    EntityName = 'setting';
                    EntitySetName = 'settings';
                    SourceTable = "Name/Value Buffer";
                    SourceTableTemporary = true;
                    ODataKeyFields = SystemId;
                    DelayedInsert = true;
                    InsertAllowed = false;
                    ModifyAllowed = false;
                    DeleteAllowed = false;

                    layout
                    {
                        area(content)
                        {
                            repeater(settings)
                            {
                                field(id; Rec.SystemId)
                                {
                                    Caption = 'Id';
                                    Editable = false;
                                }
                                field(name; Rec.Name)
                                {
                                    Caption = 'Name';
                                }
                                field(value; Rec.Value)
                                {
                                    Caption = 'Value';
                                }
                            }
                        }
                    }

                    trigger OnOpenPage()
                    begin
                        Rec.Init();
                        Rec.ID := 1;
                        Rec.Name := 'companyName';
                        Rec.Value := CompanyName();
                        Rec.Insert();
                    end;
                }
                field(displayName; Rec.Name)
                {
                    Caption = 'displayName';
                }
            }
        }
    }
}
