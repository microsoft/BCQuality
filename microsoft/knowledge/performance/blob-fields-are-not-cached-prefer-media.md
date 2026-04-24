---
bc-version: [all]
domain: performance
keywords: [blob, media, mediaset, cache, image, thumbnail]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Blob fields are never cached — prefer Media or MediaSet for images

## Description

`Blob` field contents are not cached by the Business Central server or the client. Every read re-fetches the full payload from the database, even when the same blob was read moments earlier in the same session. For images displayed on a page, this turns into a database round-trip per render.

`Media` and `MediaSet` are purpose-built for this and behave differently in two ways that matter for performance. First, they are cached on the client, so subsequent renders of the same image do not re-hit the database. Second, the platform generates a thumbnail when the data is saved, so a list or card page can show the thumbnail immediately and lazy-load the full-resolution image — typically via a Page Background Task — only when needed.

`Blob` remains appropriate for non-image binary data that is written once and rarely read, or for data the platform does not need to render. For any field that is displayed repeatedly — profile pictures, item images, logos on documents — `Media` or `MediaSet` is the default.

## Best Practice

Store images in `Media` or `MediaSet` fields. Bind the thumbnail to the page; load full-resolution data asynchronously when the user opens the full view. Reserve `Blob` for opaque payloads that are not rendered in the UI.

## Anti Pattern

An Item Image field defined as `Blob` and shown directly on a list page. Every scroll re-fetches every image from SQL, the list page load time scales with row count and image size, and no client-side caching mitigates the cost.
