enum 50815 "Upgrade Sample EnumInsert Bad"
{
    Extensible = true;

    value(0; First) { Caption = 'First'; }

    // Inserting at ordinal 1 shifts everything below. Every row that stored
    // ordinal 1 before now resolves to NewMiddleValue.
    value(1; NewMiddleValue) { Caption = 'New middle value'; }

    value(2; Second) { Caption = 'Second'; }
    value(3; Third) { Caption = 'Third'; }
}

enum 50816 "Upgrade Sample EnumRemove Bad"
{
    Extensible = true;

    value(0; First) { Caption = 'First'; }
    // value(1; Second) removed without obsoletion.
    // Existing rows storing ordinal 1 no longer resolve to any declared value.
    value(2; Third) { Caption = 'Third'; }
}
