report 50110 "Sample Item Barcode Label"
{
    UsageCategory = Tasks;
    ApplicationArea = All;
    Caption = 'Sample Item Barcode Label';

    dataset
    {
        dataitem(Item; Item)
        {
            column(No_; "No.") { }
            column(Barcode1D; BarcodeText) { }
            column(Barcode2D; QRCodeText) { }

            trigger OnAfterGetRecord()
            var
                BarcodeFontProvider: Interface "Barcode Font Provider";
                BarcodeFontProvider2D: Interface "Barcode Font Provider 2D";
            begin
                // One-dimensional: "Barcode Font Provider" declares both
                // ValidateInput and EncodeFont - call both.
                BarcodeFontProvider := Enum::"Barcode Font Provider"::IDAutomation1D;
                BarcodeFontProvider.ValidateInput("No.", BarcodeSymbology);
                BarcodeText := BarcodeFontProvider.EncodeFont("No.", BarcodeSymbology);

                // Two-dimensional: "Barcode Font Provider 2D" declares only
                // EncodeFont - there is no ValidateInput to call here.
                BarcodeFontProvider2D := Enum::"Barcode Font Provider 2D"::IDAutomation2D;
                QRCodeText := BarcodeFontProvider2D.EncodeFont("No.", BarcodeSymbology2D);
            end;
        }
    }

    var
        BarcodeSymbology: Enum "Barcode Symbology";
        BarcodeSymbology2D: Enum "Barcode Symbology 2D";
        BarcodeText: Text;
        QRCodeText: Text;

    trigger OnInitReport()
    begin
        BarcodeSymbology := Enum::"Barcode Symbology"::Code39;
        BarcodeSymbology2D := Enum::"Barcode Symbology 2D"::"QR-Code";
    end;

    // Layout requirement (can't be enforced in AL, so it's stated here):
    // the Barcode1D column's text box must use the real, purchased font
    // name - IDAutomationHC39M for Code 39 - never an evaluation name
    // like "IDAutomationSHC39M Demo". Per Microsoft Learn, using the
    // evaluation name in a Business Central online production
    // environment means "the barcode won't render" at all. The
    // Barcode2D column's font name is IDAutomation2D (IDAutomation2D
    // MaxiCode for Maxicode specifically).
}
