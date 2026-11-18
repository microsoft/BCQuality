table 50364 "Sample Employee Detail Good"
{
    Caption = 'Employee Detail';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Employee No."; Code[20])
        {
            Caption = 'Employee No.';
        }
        field(2; "National ID"; Text[30])
        {
            Caption = 'National ID';
            DataClassification = EndUserIdentifiableInformation;
            // Masked on screen as a convenience; access is governed by permissions.
            MaskType = Concealed;
        }
    }

    keys
    {
        key(PK; "Employee No.") { Clustered = true; }
    }
}

codeunit 50364 "Sample Api Key Store Good"
{
    procedure SetApiKey(ApiKey: SecretText)
    begin
        // A credential is not a table field at all.
        IsolatedStorage.Set('SampleApiKey', ApiKey, DataScope::Module);
    end;
}
