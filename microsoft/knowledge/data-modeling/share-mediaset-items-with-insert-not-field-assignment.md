---
bc-version: [all]
domain: data-modeling
keywords: [mediaset, media, insert, field-assignment, tenant-media, delete-integrity, sharing]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Share MediaSet items with Insert instead of field assignment

## Description

`Media` and `MediaSet` fields store IDs that reference tenant media system tables. When a record is deleted, the runtime looks for other references only in the same table and field index; it does not scan every table. Directly assigning a media-set field between different table types copies the ID without registering a separate media-set reference, so deleting one record can remove media that the other record still appears to reference.

## Best Practice

When sharing media between different tables, iterate the source `MediaSet` and call `Target.MediaSetField.Insert(Source.MediaSetField.Item(Index))`, then modify the target record. Direct field assignment is safe only when source and target are the same record subtype and use the same field ID. This concern is about reference/delete integrity, not the separate performance cost of `ModifyAll` on tables with media fields.

See sample: `share-mediaset-items-with-insert-not-field-assignment.good.al`.

## Anti Pattern

`Target.Picture := Source.Picture;` where the two variables refer to different table types or different media-field IDs. The code copies an opaque ID, but the platform does not know that two independent fields now share the media object.

See sample: `share-mediaset-items-with-insert-not-field-assignment.bad.al`.
