// Demonstration only. Shows the recommended pattern: the extension layout is an explicitly named, described option.
// Making it the company default is a documented setup step on the Report Layouts page, not an assumption.

reportextension 50221 "Customer List With Region Good" extends "Customer - List"
{
    dataset
    {
        add(Customer)
        {
            column(Region_Code; "Territory Code") { }
        }
    }

    rendering
    {
        layout(CustomerListWithRegion)
        {
            Type = Word;
            LayoutFile = './layouts/CustomerListWithRegion.docx';
            Caption = 'Customer list with region';
            Summary = 'Customer list including the territory. Choose it on the request page, or set it as default on the Report Layouts page.';
        }
    }
}
