codeunit 50100 "Sales Review Agent Factory"
{
    procedure GetDefaultProfile(var TempAllProfile: Record "All Profile" temporary)
    begin
        // Profile exists only as a user personalization in the design sandbox.
        TempAllProfile."Profile ID" := 'SALES REVIEW SANDBOX';
        TempAllProfile.Insert();
    end;
}
