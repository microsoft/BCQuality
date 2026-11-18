codeunit 50341 "Sample Loyalty Install Bad"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        GuidedExperience: Codeunit "Guided Experience";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
    begin
        // Registered once at install time: the entry and its translations are never refreshed.
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
