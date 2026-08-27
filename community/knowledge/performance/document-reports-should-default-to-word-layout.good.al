report 50140 "Contoso Sales Quote Confirmation"
{
    DefaultRenderingLayout = Word;

    rendering
    {
        layout(Word)
        {
            Type = Word;
            LayoutFile = './Layouts/SalesQuoteConfirmation.docx';
            Caption = 'Word Layout';
        }
    }
}
