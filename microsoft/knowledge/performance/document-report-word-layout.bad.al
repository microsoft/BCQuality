report 50105 "Sales Quote Confirmation"
{
    UsageCategory = Documents;
    ApplicationArea = All;

    rendering
    {
        layout(RDLC)
        {
            Type = RDLC;
            LayoutFile = './Layouts/SalesQuoteConfirmation.rdl';
        }
    }

    DefaultRenderingLayout = RDLC;
}
