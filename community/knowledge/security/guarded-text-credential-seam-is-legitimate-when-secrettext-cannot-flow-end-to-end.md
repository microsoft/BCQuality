---
bc-version: [23..]
domain: security
keywords: [secrettext, text-seam, interface, nondebuggable, unwrap, lc0043, pragma, half-conversion, test-double]
technologies: [al]
countries: [w1]
application-area: [all]
---

# A guarded Text credential seam is legitimate when SecretText cannot flow end to end

> Contributions welcome — open a PR to refine or extend this article.

## Description

`SecretText` can only protect a credential along a path where every API accepts it. Some seams are typed `Text` by design: an injectable interface whose test double asserts *where* the credential travels (header versus body), or a legacy consumer that takes `Text`. Retyping such a seam to `SecretText` does not complete the conversion — the value must become `Text` again at the seam, and `SecretText.Unwrap()` is on-premises only (see `nondebuggable-required-when-unwrapping-secrettext.md`). A cloud app therefore cannot convert this path end to end, and a partial conversion is worse than none: it either does not build for the cloud target or destroys the test that pinned the credential's placement. An analyzer such as LinterCop LC0043 flags the `Text` seam; the rule is right in general and wrong at exactly this location.

## Best Practice

When a `Text` seam cannot be removed, keep it `Text` and guard it instead: mark every procedure that touches the plain value `[NonDebuggable]`, keep the plain-text path as short as possible, store the value encrypted at rest (`IsolatedStorage` with `SetEncrypted`), and suppress the analyzer with a `#pragma` scoped to the exact statements, restored immediately, with a comment naming the seam that justifies it. Prefer removing the seam when the callee has a `SecretText`-aware API (`HttpHeaders.Add`, `HttpContent.WriteFrom`, `SetSecretRequestUri` — see `secrettext-with-httpclient.md`); the guarded `Text` seam is the fallback, not the default.

See sample: `guarded-text-credential-seam-is-legitimate-when-secrettext-cannot-flow-end-to-end.good.al`.

## Anti Pattern

A review finding that demands `SecretText` on a guarded `Text` seam without checking whether the value can stay `SecretText` up to the sink. Acting on it produces the half conversion: a `SecretText` parameter that is immediately `Unwrap()`-ed to call the `Text` seam, or a seam retyped to `SecretText` whose test double can no longer assert the credential's placement. Signals to detect the half conversion: `Unwrap()` in a cloud-targeted app, or a `SecretText` parameter converted back to `Text` within the same procedure.

See sample: `guarded-text-credential-seam-is-legitimate-when-secrettext-cannot-flow-end-to-end.bad.al`.
