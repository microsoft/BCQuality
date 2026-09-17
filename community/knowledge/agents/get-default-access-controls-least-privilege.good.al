permissionset 50100 "SALES REVIEW AGENT"
{
    Assignable = true;
    Caption = 'Sales Review Agent';
    Permissions =
        tabledata "Sales Header" = R,
        tabledata "Sales Line" = R;
}

codeunit 50100 "Sales Review Agent Factory"
{
    procedure GetDefaultAccessControls(var TempAccessControlBuffer: Record "Access Control Buffer" temporary)
    var
        CurrentModuleInfo: ModuleInfo;
        RoleIdTok: Label 'SALES REVIEW AGENT', Locked = true;
    begin
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        Clear(TempAccessControlBuffer);
        TempAccessControlBuffer."Company Name" := CopyStr(CompanyName(), 1, MaxStrLen(TempAccessControlBuffer."Company Name"));
        TempAccessControlBuffer.Scope := TempAccessControlBuffer.Scope::System;
        TempAccessControlBuffer."App ID" := CurrentModuleInfo.Id;
        TempAccessControlBuffer."Role ID" := RoleIdTok;
        TempAccessControlBuffer.Insert();
    end;
}
