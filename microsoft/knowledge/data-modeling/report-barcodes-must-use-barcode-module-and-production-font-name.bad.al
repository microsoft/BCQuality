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
            begin
                // WRONG: hand-rolled "encoding" instead of the Barcode
                // module's provider/encoder API. This is not wrong merely
                // because the delimiter was added by hand - Code 39's own
                // symbology does use "*" as its start/stop character
                // (Microsoft Learn, "Barcode Fonts with Business Central
                // Online"). It's wrong because it's demonstrably mismatched
                // with what encoding "No." through the real API would
                // produce:
                // - it skips ValidateInput, so a "No." value outside Code
                //   39's character set, or one that needs a checksum this
                //   code never applies, reaches the font unvalidated;
                // - IDAutomation 1D Provider's own EncodeFont output for
                //   Code 39 wraps the value in "(" / ")", not literal "*"
                //   (BCApps' own encoder test: EncodeFont('1234', Code39)
                //   = '(1234)') - the paired font maps those parentheses to
                //   the real start/stop glyph, so a string built with
                //   literal asterisks is simply the wrong characters for
                //   that font, on top of carrying no real checksum.
                BarcodeText := '*' + "No." + '*';
            end;
        }
    }

    var
        BarcodeText: Text;
}
