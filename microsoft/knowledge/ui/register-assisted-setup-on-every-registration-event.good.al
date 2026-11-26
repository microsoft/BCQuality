codeunit 50340 "Sample Loyalty Setup Reg. Good"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterAssistedSetup', '', true, true)]
    local procedure RegisterLoyaltySetup()
    var
        GuidedExperience: Codeunit "Guided Experience";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
    begin
        // Runs on every registration event so the framework can refresh the entry and its translations.
        GuidedExperience.InsertAssistedSetup(
            SetupTitleTxt,
            SetupShortTitleTxt,
            SetupDescriptionTxt,
            2,
            ObjectType::Page,
            Page::"Sample Loyalty Setup Wizard",
            AssistedSetupGroup::GettingStarted,
            '',
            VideoCategory::Uncategorized,
            '');
    end;

    var
        SetupTitleTxt: Label 'Set up customer loyalty';
        SetupShortTitleTxt: Label 'Customer loyalty';
        SetupDescriptionTxt: Label 'Choose the loyalty levels and the points that customers earn.';
}
