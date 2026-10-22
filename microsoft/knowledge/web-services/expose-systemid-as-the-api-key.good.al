page 50344 "WS SystemId Key Good"
{
    PageType = API;
    Caption = 'customer';
    APIPublisher = 'contoso';
    APIGroup = 'sales';
    APIVersion = 'v1.0';
    EntityName = 'customer';
    EntitySetName = 'customers';
    ODataKeyFields = SystemId;
    SourceTable = Customer;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(records)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'id';
                    Editable = false;
                }

                page 50346 "WS Configuration Key Good"
                {
                    PageType = API;
                    APIPublisher = 'contoso';
                    APIGroup = 'configuration';
                    APIVersion = 'v1.0';
                    EntityName = 'setting';
                    EntitySetName = 'settings';
                    SourceTable = "Name/Value Buffer";
                    SourceTableTemporary = true;
                    ODataKeyFields = Name;
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
                field(number; Rec."No.")
                {
                    Caption = 'number';
                }
                field(displayName; Rec.Name)
                {
                    Caption = 'displayName';
                }
            }
        }
    }
}
