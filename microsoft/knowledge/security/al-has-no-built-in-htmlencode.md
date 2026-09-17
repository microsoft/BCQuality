---
bc-version: [all]
domain: security
keywords: [html, xss, encoding, htmlencode, injection, email]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL has no built-in HtmlEncode — encode HTML output by hand or avoid it

## Description

AL does not ship a built-in `HtmlEncode` (or equivalent) function. Code that builds an HTML fragment — an email body, a report header, a chart label rendered as HTML — by concatenating record-field values into a string is therefore unencoded by default, and any `<`, `>`, `&`, or `"` in the user content is interpreted as markup by the receiving renderer. The result is cross-site scripting in the recipient's mail client, browser, or report viewer. The absence of a built-in encoder is non-obvious to anyone used to platforms where `HtmlEncode` is a one-liner.

## Best Practice

Replace the four characters by hand before concatenating user content into HTML: `&` → `&amp;` first, then `<` → `&lt;`, `>` → `&gt;`, `"` → `&quot;`. Centralize the substitution in one helper so every HTML producer in the extension uses the same encoder. Better still, do not build raw HTML at all — use a structured format (JSON for an API payload, a report layout for a printed document) and let the renderer do the encoding. See sample: [`al-has-no-built-in-htmlencode.good.al`](al-has-no-built-in-htmlencode.good.al).

## Anti Pattern

`HtmlContent := '<div>Welcome ' + UserName + '!</div>'` — any record-field value or user input concatenated directly into an HTML string. Reviewers should flag any string concatenation whose right-hand operand is a field, a parameter, or any non-literal value, and whose surrounding context contains HTML tags (`<`, `</`, `<br`, `<table`, `<a href=`). See sample: [`al-has-no-built-in-htmlencode.bad.al`](al-has-no-built-in-htmlencode.bad.al).
