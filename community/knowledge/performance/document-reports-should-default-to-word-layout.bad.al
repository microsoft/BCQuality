report 50140 "Contoso Sales Quote Confirmation"
{
    // Document report defaulted to RDLC out of habit — inherits the
    // sandboxed-app-domain cost for no reason tied to this report's content.
    DefaultRenderingLayout = RDLC;

    rendering
    {
        layout(RDLC)
        {
            Type = RDLC;
            LayoutFile = './Layouts/SalesQuoteConfirmation.rdl';
        }
    }
}
