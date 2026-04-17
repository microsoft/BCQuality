---
bc-version: [26..28]
domain: security
keywords: [nondebuggable, secrettext, attribute, parse]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use NonDebuggable when parsing secrets

> **Seed article.** Converted from an existing security-review prompt to bootstrap the BCQuality security corpus. Domain stewards should expand, restructure, and refine as needed.

## Description

SecretText transit (assignment between SecretText variables, parameters, and return values) is protected automatically. Extracting a secret from a Text source — for example, reading an access token out of a parsed JSON response — is a legitimate Text-to-SecretText conversion during which the plaintext exists. The [NonDebuggable] attribute prevents debuggers (regular and snapshot) from inspecting the procedure's locals, parameters, and return at that moment.

## Best Practice

Apply [NonDebuggable] to any procedure that reads a response body, parses it, and assigns the extracted secret to a SecretText out-parameter or return. Keep the procedure narrow: it SHOULD do the minimum work required to obtain the SecretText, and nothing else.

See sample: `samples/security/use-nondebuggable-when-parsing-secrets/good.al`.

## Anti Pattern

Parsing a token response in a normal (debuggable) procedure. The plaintext token is visible in debug sessions and snapshots taken during the parse.

See sample: `samples/security/use-nondebuggable-when-parsing-secrets/bad.al`.

