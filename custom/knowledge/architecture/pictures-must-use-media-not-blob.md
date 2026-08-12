---
bc-version: [all]
domain: architecture
keywords: [blob, media, mediaset, picture-field, image-field, table-design]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Pictures must be stored in a Media/MediaSet field, not BLOB

## Description

`BLOB` is still a valid AL field type for arbitrary binary data, but it is
not the right choice for storing pictures or images. Microsoft's current
recommendation is the `Media` field type for a single image, or
`MediaSet` when a record needs several image variants (e.g. multiple
sizes). Media/MediaSet integrate with the platform's picture control, the
media repository, image caching, and thumbnail generation — none of which
a plain `BLOB` field gets. A `BLOB` field storing a picture works, but it
is the legacy approach: no caching, no thumbnail support, and no
integration with the standard picture controls used across Business
Central pages.

`BLOB` remains the correct choice for genuinely arbitrary binary payloads
that are not images and don't benefit from the media pipeline (e.g. a raw
file attachment blob unrelated to picture rendering).

## Best Practice

```al
field(50; Picture; Media)
{
    Caption = 'Picture';
}
```

## Anti Pattern

```al
field(50; Picture; BLOB)
{
    Caption = 'Picture';
}
```

A `BLOB` field named "Picture" compiles and stores the image bytes, but
it misses the picture control integration, caching, and thumbnail
generation that a `Media`/`MediaSet` field provides for free — the anti
pattern is choosing `BLOB` for image storage out of habit rather than
recognizing that the field is holding a picture, not generic binary data.
