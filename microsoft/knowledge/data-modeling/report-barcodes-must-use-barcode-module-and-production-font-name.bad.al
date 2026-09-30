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
            column(Barcode; BarcodeText) { }

            trigger OnAfterGetRecord()
            var
                BarcodeFontProvider: Interface "Barcode Font Provider";
            begin
                // WRONG: a one-dimensional IDAutomation provider path that
                // calls EncodeFont without ValidateInput. "Barcode Font
                // Provider" (1D) declares both, and IDAutomation 1D
                // Provider's EncodeFont does not validate on its own - it
                // hands the text straight to the font encoder. Code 39
                // accepts only 0-9, A-Z, space and - . $ / + % *, but an
                // Item "No." can legally contain characters outside that
                // set (e.g. "_" or "#"). Such a value is never rejected;
                // it silently reaches the font as an unscannable barcode.
                BarcodeFontProvider := Enum::"Barcode Font Provider"::IDAutomation1D;
                BarcodeText := BarcodeFontProvider.EncodeFont("No.", BarcodeSymbology);
            end;
        }
    }

    var
        BarcodeSymbology: Enum "Barcode Symbology";
        BarcodeText: Text;

    trigger OnInitReport()
    begin
        BarcodeSymbology := Enum::"Barcode Symbology"::Code39;
    end;
}
