---
bc-version: [23..]
domain: copilot
keywords: [aoai-operation-response, issuccess, generatechatcompletion, getlastmessage, geterror, getstatuscode, azure-openai, ai-error-handling]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Check the AOAI Operation Response before using generated output

## Description

`GenerateChatCompletion`, `GenerateTextCompletion`, and `GenerateEmbeddings` in codeunit `Azure OpenAI` report the outcome of the service call in the `AOAI Operation Response` passed by `var`; a failed completion does not stop the AL code. Such failures are routine: throttling, content filtering, timeouts, token limits, or overconsumption of Business Central AI resources. (Setup problems such as a missing capability can still raise errors before the call.) Code that calls `GetLastMessage()` or uses the returned text without checking `IsSuccess()` then treats empty or unrelated text as the model's answer, and may parse it, show it as a proposal, or write it to records.

Agents familiar with SDKs that throw on failure usually omit this check, because the API looks like it would raise an error.

## Best Practice

Immediately after each generate call, test `AOAIOperationResponse.IsSuccess()`. On failure, stop and give the user a clear, actionable message. Use `GetError()` and `GetStatusCode()` for telemetry or to distinguish retryable conditions, without exposing raw service text as the only explanation. Read `GetLastMessage()` or the function-call results only on the success path.

Both samples use the BC23+ own-resource `SetAuthorization(ModelType, Endpoint, Deployment, ApiKey)` overload, with configuration supplied by the caller and the key passed as `SecretText`. Response checking is independent of the authorization mode. If using Business Central AI resources, choose an overload supported by the target version; the two-argument `SetManagedResourceAuthorization` requires BC28+. See [version-qualified authorization guidance](call-azure-openai-through-the-ai-module.md).

Each companion independently declares the `Reminder Draft Demo` table, its `Body Text` field, and the `Draft Payment Reminder` capability enum value. Before running either sample, register and activate that capability using the [install/upgrade registration pattern](register-copilot-capability-on-install-and-upgrade.md), adapted to this enum value, and pass an existing reminder draft record. The enumextension supplies the AL symbol; it does not register the capability at runtime.

See sample: [`check-aoai-operation-response-before-using-output.good.al`](check-aoai-operation-response-before-using-output.good.al).

## Anti Pattern

A generate call followed by `GetLastMessage()`, by use of the returned text, or by parsing or persisting the result, with no `IsSuccess()` check on that response in between. A check that only logs the failure and then continues with the output is the same defect.

See sample: [`check-aoai-operation-response-before-using-output.bad.al`](check-aoai-operation-response-before-using-output.bad.al).

## References

[Build the Copilot capability in AL, Generation](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/ai-build-capability-in-al#generation) (`IsSuccess` checks the operation before `GetLastMessage`), [Azure OpenAI codeunit](https://learn.microsoft.com/en-us/dynamics365/business-central/application/system-application/codeunit/system.ai.azure-openai) (the response object reports successful or failed execution), and [Business Central AI resources](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/ai-dev-tools-resources) (handle overconsumption through `AOAI Operation Response`).
