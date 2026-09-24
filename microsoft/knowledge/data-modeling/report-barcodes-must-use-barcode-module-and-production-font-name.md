---
bc-version: [all]
domain: data-modeling
keywords: [barcode, qr-code, barcode-font-provider, barcode-font-provider-2d, report-layout, saas, idautomation, code-39, checksum]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Generate report barcodes through the Barcode module, with the production font name

## Description

Business Central's barcode support lives in the System Application's
`Barcode` module (`src/System Application/App/Barcode`): `interface
"Barcode Font Provider"` / `"Barcode Font Provider 2D"`, `enum "Barcode
Symbology"` / `"Barcode Symbology 2D"`, and built-in implementations
(`codeunit 9215`/`9221`). A report encodes a data string via this API;
the layout then displays it using a barcode *font*.

The two interfaces are not symmetric: `"Barcode Font Provider"` (1D)
declares both `ValidateInput` and `EncodeFont`; `"Barcode Font Provider
2D"` declares only `EncodeFont` (see Source). BCApps' `Item GTIN Label`
report reflects that split exactly — it validates then encodes through
the 1D provider, but only encodes through the 2D provider, for the same
"No." value.

On Business Central online this needs no setup ("the IDAutomation fonts
are automatically available as part of the service" — Microsoft Learn),
unlike on-premises, where fonts must be purchased and installed. That
ease hides a SaaS-specific trap the API doesn't cover: naming the actual
font. IDAutomation ships both a purchased font and a same-looking
evaluation font per version (Code 39: `IDAutomationHC39M` purchased vs.
`IDAutomationSHC39M Demo`) — per Microsoft Learn, "be sure to use the
purchased font name... If you use the evaluation font name, the barcode
won't render." The wrong name produces nothing, in the layout not AL, so
no reviewer catches it reading the object.

## Best Practice

Encode through the real API, matching the calls to what the chosen
interface actually declares. One-dimensional: declare `Interface
"Barcode Font Provider"` and call both `ValidateInput` and `EncodeFont`
— skipping validation lets a value outside the character set, or one
needing a checksum setting never applied, reach the font unchecked.
Two-dimensional: declare `Interface "Barcode Font Provider 2D"` and call
`EncodeFont` alone — there is no `ValidateInput` on this interface.

Treat naming the production font in the layout as equally required, not
an afterthought. Two-dimensional symbologies other than Maxicode use
`IDAutomation2D` (Maxicode: `IDAutomation2D MaxiCode`); one-dimensional
symbologies use the purchased version name (e.g. `IDAutomationHC39M` for
Code 39), never a name containing `Demo`.

See sample: [`report-barcodes-must-use-barcode-module-and-production-font-name.good.al`](report-barcodes-must-use-barcode-module-and-production-font-name.good.al).

## Anti Pattern

Constructing a barcode string by hand instead of using the module's
provider/encoder API — not because a manual delimiter is inherently
wrong (Code 39's own symbology does use `*` as start/stop; Microsoft
Learn's font table says so), but because hand-rolled construction is
demonstrably mismatched with what the real encoder produces: it skips
`ValidateInput` (so a value outside the character set, or needing a
checksum/extended-charset setting never applied, reaches the font
unvalidated), and IDAutomation 1D Provider's own Code 39 output is
wrapped in `(`/`)`, not literal `*` (BCApps test:
`EncodeFont('1234', Code39) = '(1234)'`) — the paired font maps those
parentheses to the real start/stop glyph, so `'*' + value + '*'` is
simply the wrong characters, plus no checksum.

Flag demonstrably invalid or mismatched hand construction, not manual
delimiter use as a category — a custom provider paired with a font that
genuinely expects literal `*` delimiters is a different, legitimate case.

A second version of the same mistake: encoding correctly, but naming the
evaluation font instead of the purchased one. Both look complete in
review and fail silently — the first because the data was never a real
barcode, the second because BC online refuses to render it.

See sample: [`report-barcodes-must-use-barcode-module-and-production-font-name.bad.al`](report-barcodes-must-use-barcode-module-and-production-font-name.bad.al).

## Source

BCApps (`src/System Application/App/Barcode/src/`):
`Barcode Provider/Font/BarcodeFontProvider.Interface.al` (1D:
`ValidateInput` + `EncodeFont`); `Barcode Provider 2D/Font/
BarcodeFontProvider2D.Interface.al` (2D: only `EncodeFont`); both read
fresh from source. `IDAutomation 1D Provider/Encoders/
IDA1DCode39Encoder.Codeunit.al` (`codeunit 9204`, regex accepts literal
`*` as plain input; `EncodeFont` → `DotNet FontEncoder.Code39`). Split
and delimiter mismatch both confirmed live: `.../Inventory/Item/
ItemGTINLabel.Report.al` (`report 6625`, validates+encodes 1D, only
encodes 2D, same value) and `.../Test/Barcode/.../IDA1DCode39Test.
Codeunit.al` (`codeunit 135044`): `EncodeFontSuccessTest('1234', Code39,
'(1234)')` — wrapped in `(`/`)`, never literal `*`.

Microsoft Learn "Adding Barcodes to Reports" and "Barcode Fonts with
Business Central Online" — quoted above, incl. the Code39 row ("`*` is
used for both start and stop delimiters").
