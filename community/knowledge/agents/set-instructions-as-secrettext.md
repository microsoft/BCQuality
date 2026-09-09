---
bc-version: [27..]
domain: agents
keywords: [setinstructions, secrettext, instructions, per-instance, resource]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Set agent instructions as SecretText on the instance

## Description

Instructions are instance data, not an enum caption. `Agent.SetInstructions` takes `SecretText` so the payload is not logged or copied as ordinary text. A Label or plaintext Text on the agent type is the wrong store: it leaks into telemetry-friendly strings and cannot vary per instance or company.

## Best Practice

Load instruction text from a resource or builder into a `SecretText` variable and call `Agent.SetInstructions(AgentUserSecurityId, Instructions)` after `Create`. Keep one instruction document per instance.

See sample: [`set-instructions-as-secrettext.good.al`](set-instructions-as-secrettext.good.al).

## Anti Pattern

Passing a `Label` or `Text` to `SetInstructions`, storing instructions in a setup Text field without wrapping as `SecretText`, or putting the prompt only in a code comment. Detection signal: `SetInstructions` with a non-`SecretText` argument, or no `SetInstructions` after `Create`.

See sample: [`set-instructions-as-secrettext.bad.al`](set-instructions-as-secrettext.bad.al).
