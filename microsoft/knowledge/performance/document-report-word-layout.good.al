report 50105 "Sales Quote Confirmation"
{
    UsageCategory = Documents;
    ApplicationArea = All;

    rendering
    {
        layout(Word)
        {
            Type = Word;
            LayoutFile = './Layouts/SalesQuoteConfirmation.docx';
            Caption = 'Word Layout';
        }
    }

    DefaultRenderingLayout = Word;
}
