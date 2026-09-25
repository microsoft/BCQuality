---
bc-version: [all]
domain: web-services
keywords: [jsonobject, jsontoken, jsonvalue, isnull, asvalue, astext, asdecimal, optional-property, json-null, payload-parsing]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Check for JSON null before converting a value

## Description

An optional property in a JSON payload can be missing or present with the value `null`, and the two cases behave differently in AL. When the Boolean result is captured, `JsonObject.Get` returns `false` for a missing key but `true` for `"email": null`, because the key exists. The conversion methods on `JsonValue` (`AsText`, `AsCode`, `AsDecimal`, `AsInteger`, `AsDate`, `AsBoolean`, and the others) fail with a runtime error when the value is `NULL` or `UNDEFINED`. Code that guards only with `Get` therefore passes its tests with the property omitted and fails in production when the sender serializes an empty field as `null`, which many services do by default.

## Best Practice

For every property that the contract allows to be optional or nullable, check three things before converting: that `Get` (or `SelectToken`) returned `true`, that the token `IsValue()` rather than an object or array, and that `AsValue().IsNull()` is `false`. Put this in one small helper per target type and decide explicitly what a missing or null property means: a default, leaving the field unchanged, or a validation error that names the property.

Required properties can still fail fast, but with an error that states the missing or null property instead of a generic conversion error. Keep a numeric or date conversion strict when the contract says the value must be a number or a date; `IsNull` covers only `null`, not a value of the wrong type.

See sample: [`check-json-null-before-converting-values.good.al`](check-json-null-before-converting-values.good.al).

## Anti Pattern

`if Json.Get('email', Token) then Email := Token.AsValue().AsText();` or an unguarded `Token.AsValue().AsDecimal()` on a property that the external contract allows to be `null`. The `Get` check makes the code look defensive, but it doesn't handle a present `null`. Detection signal: an `As<Type>()` call on a `JsonValue` obtained from an external payload with no preceding `IsNull()` check on the same token, where the property isn't documented as always non-null.

See sample: [`check-json-null-before-converting-values.bad.al`](check-json-null-before-converting-values.bad.al).

## References

- [JsonObject.Get method](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/jsonobject/jsonobject-get-method)
- [JsonValue.AsText method: fails on NULL or UNDEFINED](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/jsonvalue/jsonvalue-astext-method)
- [JsonValue.IsNull method](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/jsonvalue/jsonvalue-isnull-method)
- [JsonToken data type](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/jsontoken/jsontoken-data-type)
