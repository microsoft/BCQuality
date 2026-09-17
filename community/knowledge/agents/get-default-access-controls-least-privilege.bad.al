codeunit 50100 "Sales Review Agent Factory"
{
    procedure GetDefaultAccessControls(var TempAccessControlBuffer: Record "Access Control Buffer" temporary)
    var
        BaseApplicationAppIdTok: Label '437dbf0e-84ff-417a-965d-ed2bb9650972', Locked = true;
    begin
        Clear(TempAccessControlBuffer);
        TempAccessControlBuffer."Company Name" := CopyStr(CompanyName(), 1, MaxStrLen(TempAccessControlBuffer."Company Name"));
        TempAccessControlBuffer.Scope := TempAccessControlBuffer.Scope::System;
        TempAccessControlBuffer."App ID" := BaseApplicationAppIdTok;
        TempAccessControlBuffer."Role ID" := 'D365 BUS FULL ACCESS';
        TempAccessControlBuffer.Insert();
    end;
}
