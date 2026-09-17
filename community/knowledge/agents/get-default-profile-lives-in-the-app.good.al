profile "SALES REVIEW AGENT"
{
    Caption = 'Sales Review Agent';
    Description = 'UI surface for the Sales Review Agent.';
    RoleCenter = "Order Processor Role Center";
    Customizations = "Sales Review Agent Sales Ord.";
}

codeunit 50100 "Sales Review Agent Factory"
{
    procedure GetDefaultProfile(var TempAllProfile: Record "All Profile" temporary)
    var
        Agent: Codeunit Agent;
        CurrentModuleInfo: ModuleInfo;
        DefaultProfileTok: Label 'SALES REVIEW AGENT', Locked = true;
    begin
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        Agent.PopulateDefaultProfile(DefaultProfileTok, CurrentModuleInfo.Id, TempAllProfile);
    end;
}
