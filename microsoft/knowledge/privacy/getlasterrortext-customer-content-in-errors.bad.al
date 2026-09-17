codeunit 50209 "Privacy Sample GetLastError Bad"
{
    procedure AddAttachment()
    var
        AttachmentFailedErr: Label 'Attachment failed: %1', Comment = '%1 = underlying error';
    begin
        if not TryAddAttachment() then
            Error(StrSubstNo(AttachmentFailedErr, GetLastErrorText()));
    end;

    procedure AddAttachmentWithConcatenation()
    var
        AttachmentFailedErr: Label 'Attachment failed: ';
    begin
        if not TryAddAttachment() then
            Error(AttachmentFailedErr + GetLastErrorText());
    end;

    [TryFunction]
    local procedure TryAddAttachment()
    begin
    end;
}
