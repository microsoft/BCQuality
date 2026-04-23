enum 50813 "Upgrade Sample EnumAdditive Good"
{
    Extensible = true;

    value(0; First) { Caption = 'First'; }
    value(1; Second) { Caption = 'Second'; }
    value(2; Third) { Caption = 'Third'; }

    // New value appended at the next free ordinal. Existing stored ordinals
    // (0, 1, 2) keep their meaning.
    value(3; NewValue) { Caption = 'New value'; }
}

enum 50814 "Upgrade Sample EnumRetire Good"
{
    Extensible = true;

    value(0; First) { Caption = 'First'; }

    value(1; Second)
    {
        Caption = 'Second';
        ObsoleteState = Removed;
        ObsoleteReason = 'Replaced by NewValue.';
        ObsoleteTag = '28.0';
    }

    value(2; Third) { Caption = 'Third'; }
}
