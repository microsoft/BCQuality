---
bc-version: [all]
domain: architecture
keywords: [xliff, translation, xlf, caption, tooltip, enu, da-dk, de-de, no-nb, sv-se, de-at]
technologies: [al]
countries: [w1]
application-area: [all]
---

## Description

CURABIS apps support the following locales: da-DK, de-DE, de-AT, nb-NO, sv-SE.
XLIFF translation is a batch operation — never line-by-line. The agent must
translate all trans-units in one pass without asking questions per string.

## Tone and register

Follow Microsoft Business Central's translation tone for each locale:

- **da-DK**: Kort, direkte, professionel. Undgå høfligheds-De. Brug infinitiv
  frem for bydeform. Brug BC-standardtermer: "Bogfør" ikke "Send til bogføring",
  "Kreditor" ikke "Leverandør", "Finanspost" ikke "Finansregistrering".
- **de-DE**: Formell, Sie-Form. BC-Standardterminologie: "Buchen", "Kreditor",
  "Sachposten". Substantive großschreiben.
- **de-AT**: Identisch mit de-DE. Keine österreichischen Dialektvarianten.
- **nb-NO**: Kort og profesjonell. BC-standardtermer: "Bokfør", "Leverandør",
  "Finanspost". Bruk infinitiv.
- **sv-SE**: Kort, professionell. BC-standardtermer: "Bokför", "Leverantör",
  "Redovisningspost". Undvik dialekt.

## Workflow — one pass, no questions

When asked to translate an XLIFF file:

1. Read the entire source `.g.xlf` file in one operation
2. Translate ALL trans-units in memory
3. Write the complete translated file in one operation
4. Do not ask questions about individual strings
5. Do not pause between strings
6. Do not ask for confirmation per trans-unit

If a term is ambiguous, apply the BC standard term for that locale and add a
single summary comment at the end — never interrupt the translation to ask.

## Terms that must NOT be translated

The following must remain in English in all locales:
- Object names used as identifiers (e.g. "Settlement Voucher")
- Field names that are part of the AL identifier (e.g. "Qty. to Invoice")
- Company names, product names, app names

## Trans-unit structure

```xml
<trans-unit id="..." size-unit="char" translate="yes" xml:space="preserve">
  <source>Post</source>
  <target state="translated">Bogfør</target>  ← da-DK example
  <note from="Developer" annotates="source" priority="2">Button caption</note>
</trans-unit>
```

State must always be `translated` — never `needs-translation` or `new`.

## Common BC terms reference

| ENU | da-DK | de-DE | nb-NO | sv-SE |
|---|---|---|---|---|
| Post | Bogfør | Buchen | Bokfør | Bokför |
| Vendor | Kreditor | Kreditor | Leverandør | Leverantör |
| Customer | Debitor | Debitor | Kunde | Kund |
| Item | Vare | Artikel | Vare | Artikel |
| G/L Entry | Finanspost | Sachposten | Finanspost | Redovisningspost |
| Amount | Beløb | Betrag | Beløp | Belopp |
| Quantity | Antal | Menge | Antall | Antal |
| Invoice | Faktura | Rechnung | Faktura | Faktura |
| Receipt | Kvittering | Empfangsschein | Kvittering | Inleverans |
| Settlement | Afregning | Abrechnung | Avregning | Avräkning |
| Voucher | Bilag | Beleg | Bilag | Verifikation |
| Cash | Kontant | Bar | Kontant | Kontant |
| Threshold | Grænse | Grenzwert | Grense | Gräns |
| Incoming | Indgående | Eingehend | Inngående | Inkommande |
| Outgoing | Udgående | Ausgehend | Utgående | Utgående |
| Handle | Håndter | Verarbeiten | Håndter | Hantera |
| Weighbridge | Vægt | Fahrzeugwaage | Vekt | Våg |
| Scrap | Skrot | Schrott | Skrap | Skrot |

## Error and warning messages

Error messages follow the BC pattern:
- da-DK: Start with capital, end with period. "Du kan ikke bogføre et tomt bilag."
- de-DE: Formal, Sie-Form. "Sie können keinen leeren Beleg buchen."
- nb-NO: "Du kan ikke bokføre et tomt bilag."
- sv-SE: "Du kan inte bokföra ett tomt verifikat."

ToolTip format (da-DK): "Angiver [hvad feltet indeholder]." — always starts
with "Angiver" for fields, "Åbner" for actions that open pages.
