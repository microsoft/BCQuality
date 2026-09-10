---
bc-version: [all]
domain: data-modeling
keywords: [blob, media, mediaset, picture-field, image-field, table-design]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Pictures must be stored in a Media/MediaSet field, not BLOB

## Description

`BLOB` is still a valid AL field type for arbitrary binary data, but it is
not the right choice for storing pictures or images. The current
recommendation is the `Media` field type for a single image, or
`MediaSet` when a record needs several independent images (e.g. multiple
product photos) — `MediaSet` is a collection of separately-imported media
objects, each with its own identity; it does not generate resized variants
or thumbnails on its own, and displaying more than one item still requires
custom page handling. Media/MediaSet integrate with the platform's
picture control and media repository, which a plain `BLOB` field does not
— but any derived preview or thumbnail image still has to be generated
explicitly and stored in its own field, regardless of which type holds the
source image.

`BLOB` remains the correct choice for genuinely arbitrary binary payloads
that are not images and don't benefit from the media pipeline (e.g. a raw
file attachment blob unrelated to picture rendering).

## Best Practice

Use `Media` for a single image, or `MediaSet` for multiple independent
images, for any field that holds a picture.

See sample: `pictures-must-use-media-not-blob.good.al`.

## Anti Pattern

A `BLOB` field named "Picture" compiles and stores the image bytes, but
it misses the picture control integration and media repository that a
`Media`/`MediaSet` field provides for free — the anti pattern is choosing
`BLOB` for image storage out of habit rather than recognizing that the
field is holding a picture, not generic binary data. A related anti
pattern: assuming `MediaSet` gives automatic image variants or thumbnails
because it sounds like a collection with derived versions — it is only a
collection of independently-imported media objects.

See sample: `pictures-must-use-media-not-blob.bad.al`.
