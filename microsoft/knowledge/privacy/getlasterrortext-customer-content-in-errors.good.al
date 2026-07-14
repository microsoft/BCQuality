codeunit 50208 "Privacy Sample GetLastError Good"
{
    procedure AddAttachmentSafely()
    var
        AttachmentFailedErr: Label 'Failed to add the attachment: %1', Comment = '%1 = underlying error shown to the user';
    begin
        if not TryAddAttachment() then
            Error(AttachmentFailedErr, GetLastErrorText());
    end;

    [TryFunction]
    local procedure TryAddAttachment()
    begin
        // Attachment logic that can fail with a customer-data-bearing error.
    end;
}
