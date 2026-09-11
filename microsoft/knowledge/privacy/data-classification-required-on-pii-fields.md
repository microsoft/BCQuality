---
bc-version: [all]
domain: privacy
keywords: [data-classification, pii, gdpr, customer-content, table-field, under-classified]
technologies: [al]
countries: [w1]
application-area: [all]
---

# DataClassification is required on table fields containing sensitive data

## Description

`DataClassification` tells the platform what kind of data a table field stores so that telemetry, GDPR data-subject requests, and the platform's audit surfaces can treat it correctly. A field declared inside a table object can set its own value or inherit a valid table-level value; a `tableextension` has no table-level value to inherit, so every Normal field it adds must set its own. When neither scope supplies a valid classification, the field remains `ToBeClassified` — a placeholder meaning "not yet reviewed", not a safe default. Leaving a field that actually holds PII (an email address, a customer name, an employee code) as `ToBeClassified`, or classifying it as `SystemMetadata` ("no user or customer data"), are both under-classifications and privacy bugs, even though the code still compiles.

## Best Practice

Set `DataClassification` to the value that matches the data the field actually stores. A `Customer."E-Mail"`-style field is `CustomerContent` (data belonging to the tenant's customers); a personal identifier such as an employee number or user ID is `EndUserIdentifiableInformation` or `EndUserPseudonymousIdentifiers` depending on whether it is directly identifying. A field that identifies an organization rather than a person — a company registration or VAT registration number — is `OrganizationIdentifiableInformation`, and a financial account identifier such as a bank account number or IBAN is `AccountData`. Choose the classification at field definition time — fixing it later is a schema change.

See sample: [`data-classification-required-on-pii-fields.good.al`](data-classification-required-on-pii-fields.good.al).

## Anti Pattern

Declaring a field that stores PII with `DataClassification = SystemMetadata` to silence the compiler warning. The field compiles but the platform now treats customer data as system metadata in telemetry, GDPR exports and admin reports.

See sample: [`data-classification-required-on-pii-fields.bad.al`](data-classification-required-on-pii-fields.bad.al).
