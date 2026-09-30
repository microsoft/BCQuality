---
bc-version: [all]
domain: data-modeling
keywords: [price-calculation, price-calculation-handler, price-calculation-setup, integration-event, pricing]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Activate a new Price Calculation Handler through OnFindSupportedSetup, not just by implementing it

## Description

`enum 7011 "Price Calculation Handler"` (`implements "Price
Calculation"`) is how a new pricing engine plugs into Business Central —
extend the enum with a value pointing at a codeunit that implements the
`Price Calculation` interface. That alone does not make the new handler
usable on any document. `codeunit 7001 "Price Calculation Mgt."` decides
which handler applies to a given line by looking up `table 7006 "Price
Calculation Setup"`, a table of `(Code, Method, Type, Asset Type,
Implementation, Enabled, Default)` rows populated at startup by its own
`OnFindSupportedSetup` event — every implementation codeunit is expected
to subscribe to that event and insert its own setup row(s). A handler
enum value with no matching setup row is real and selectable in the enum
itself, but never chosen for any actual sale, purchase, or job line,
because `Price Calculation Mgt.` has no setup row that names it.

`FindSetup` resolves a handler in two stages, and only the second one
looks at `Default`. It first asks `codeunit 7004 "Price Calculation Dtld.
Setup"` to match the line against `table 7008 "Dtld. Price Calculation
Setup"` ("Detailed Price Calculation Setup", keyed to an exact
`Method`/`Type`/`Asset Type`/`Source`/`Asset No.` combination via its own
`"Setup Code"`); on a match it does `PriceCalculationSetup.Get(...
"Setup Code")` directly, with no `Default` filter. Only when no detailed
row matches does it fall back to `SetRange(Default, true)` plus
`SetRange(Method, ...)` to pick the one catch-all row for that
combination. A row without `Default := true` is invisible to *that*
fallback, but not invisible outright — a detailed-setup row can still
select it by naming its `Code`. A row whose `Method` matches neither path
is invisible either way — same symptom, different cause.

## Best Practice

Ship a new `Price Calculation Handler` value together with an
`OnFindSupportedSetup` subscriber that inserts at least one `Price
Calculation Setup` record naming it as the `Implementation`, for the
relevant `Method` (e.g. `"Lowest Price"`), `Type` (`Sale`/`Purchase`), and
`Asset Type`. `Default := true` is required only when this row is the
*fallback* for that combination — the row `FindSetup`'s own
`SetRange(Default, true)` branch selects when no more specific setup
applies. A handler meant to be selected only for specific customers or
items should instead be reachable through a matching `"Dtld. Price
Calculation Setup"` row; `FindSetup` resolves that before it ever checks
`Default`, so it needs no `Default := true`.

See sample: [`activate-new-price-calculation-handler-via-onfindsupportedsetup.good.al`](activate-new-price-calculation-handler-via-onfindsupportedsetup.good.al).

## Anti Pattern

Extending `Price Calculation Handler` and implementing the `Price
Calculation` interface, without subscribing to `OnFindSupportedSetup` to
insert a setup record. The new handler exists, compiles, and can even be
selected manually if a user creates their own `Price Calculation Setup`
row through the UI — but ships with no default row, so it's never active
for anyone until someone notices it's missing and configures it by hand.

See sample: [`activate-new-price-calculation-handler-via-onfindsupportedsetup.bad.al`](activate-new-price-calculation-handler-via-onfindsupportedsetup.bad.al).

## Source

BCApps (`src/Layers/W1/BaseApp/Pricing/Calculation/`):
`PriceCalculationHandler.Enum.al` (`enum 7011 "Price Calculation Handler"
implements "Price Calculation"`); `PriceCalculationMgt.Codeunit.al`
(`OnFindSupportedSetup(var TempPriceCalculationSetup: Record "Price
Calculation Setup" temporary)`, and `FindSetup(...): Boolean`, which
first calls `PriceCalculationDtldSetup.FindSetup(DtldPriceCalcSetup)` and
on a match does `PriceCalculationSetup.Get(... "Setup Code")` with no
`Default` filter — only on failure does it fall back to
`SetRange(Enabled, true)`, `SetRange(Default, true)`, `SetRange(Method,
...)`); `PriceCalculationSetup.Table.al` (`table 7006 "Price Calculation
Setup"`: `Code`, `Method`, `Type`, `"Asset Type"`, `Implementation`,
`Enabled`, `Default`); `PriceCalculationDtldSetup.Codeunit.al` (`codeunit
7004 "Price Calculation Dtld. Setup"`, `FindSetup(var DtldPriceCalcSetup:
Record "Dtld. Price Calculation Setup"): Boolean`, matching progressively
looser `Source Group`/`Source No.`/`Asset Type`/`Asset No.` combinations —
never `Default`); `DtldPriceCalculationSetup.Table.al` (`table 7008 "Dtld.
Price Calculation Setup"`, Caption "Detailed Price Calculation Setup",
`"Setup Code"` relates to `"Price Calculation Setup".Code where(Enabled =
const(true))` — no `Default` condition).

Microsoft Learn, "Extending Price Calculations": "Each codeunit that
implements the Price Calculation interface must subscribe to the
OnFindSupportedSetup() event... to fill the price calculation setup
table." Same article: "You can enter detailed setup records for
non-default setup lines... If a matching setup is found its
implementation is used... If there is no matching setup exception, we
use the default implementation."
(https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-extending-best-price-calculations)
