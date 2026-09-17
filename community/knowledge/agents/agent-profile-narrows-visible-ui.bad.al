codeunit 50100 "Sales Review Agent Factory"
{
    procedure GetDefaultProfile(var TempAllProfile: Record "All Profile" temporary)
    begin
        TempAllProfile."Profile ID" := 'BUSINESS MANAGER';
        TempAllProfile.Insert();
    end;
}
