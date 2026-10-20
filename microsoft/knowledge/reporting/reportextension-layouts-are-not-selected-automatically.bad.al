// Demonstration only. Shows the wrong pattern: the new layout is assumed to replace the base report's layout.

reportextension 50220 "Customer List With Region Bad" extends "Customer - List"
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
        // BAD: the region column is shown only in this layout, and nothing selects it. After deployment
        // the report keeps printing its own default layout, so users never see the region.
        layout(CustomerListWithRegion)
        {
            Type = Word;
            LayoutFile = './layouts/CustomerListWithRegion.docx';
        }
    }
}
