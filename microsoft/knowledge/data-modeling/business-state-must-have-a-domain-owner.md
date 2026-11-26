---
bc-version: [all]
domain: data-modeling
keywords: [job-queue-entry, recurring-job, calcformula-exist, isempty]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Business state must have a domain owner

## Description

Business Central's normal successful finalization removes a non-recurring Job Queue Entry. An `exist` FlowField over that entry then correctly returns false, even if the handler recorded a business issue that remains unresolved. This rule addresses business-state dependence on the lifetime of execution records, including custom staging or log rows that a visible cleanup path removes.

## Best Practice

Persist an unresolved business issue on the entity that owns its resolution, or on a domain record with the required lifetime. A queue entry can reference that owner; deleting the entry must not resolve the issue. A standard business-table extension is appropriate when the added state belongs to that entity.

- Establish the actual execution-record lifecycle. In the default Job Queue path, successful non-recurring jobs are removed and recurring jobs are rescheduled. On Hold, manual recurrence, or an event subscriber handling cleanup can alter that path; do not assume every job is deleted.
- Trace the business-facing `exist`, `IsEmpty`, or equivalent existence read to the records it uses. Report a defect only when an identified technical deletion path changes the business result without satisfying the business resolution condition.
- Distinguish an opened obligation from a derived value. In the samples, the indicator means an inspection has opened an unresolved contact issue; it is not an email-validity flag. A new customer has no opened issue until inspection. Once opened, the issue remains until the explicit resolution command validates a nonblank email.
- Technical indicators such as "a job is scheduled" may legitimately depend on queue existence. Stable references, disposable execution metadata, and caches whose readers fall back to domain data are also valid. A table extension, ordinary FlowField, or buffer name alone is not evidence of this defect.
- When the supplied source and documented lifecycle do not establish the business consumer and deletion/resolution mismatch, emit no ownership finding. Existing persisted data needs a migration assessment before changing its owner.

See sample: [`business-state-must-have-a-domain-owner.good.al`](business-state-must-have-a-domain-owner.good.al). Customer owns the opened issue; successful job cleanup leaves it intact, and only the validated resolution command clears it. The caller supplies `Customer.RecordId` in the existing `Record ID to Process` field; the good example does not extend Job Queue Entry.

## Anti Pattern

An authoritative business indicator depends on whether execution or staging rows exist, while those rows can be deleted without satisfying the business completion or resolution condition. Identify the obligation or completion condition, its existence-based reader, the applicable deletion path, and the business result that incorrectly changes. The same defect can be introduced by changing only a page/report/codeunit consumer or a cleanup routine; adding fields is not required.

See sample: [`business-state-must-have-a-domain-owner.bad.al`](business-state-must-have-a-domain-owner.bad.al). The one-off inspection records an open issue on Job Queue Entry and returns successfully. Normal finalization deletes the entry, so the customer's FlowField loses the issue without any resolution command. No custom cleanup procedure is needed to trigger the failure.

## References

- [Successful non-recurring jobs are removed](https://learn.microsoft.com/en-us/dynamics365/business-central/admin-job-queues-schedule-tasks)
- [Job Queue Entry: result handling and finalization](https://github.com/microsoft/BCApps/blob/3df81bcd9eff84993c51c80b4c20350665ee1f52/src/Layers/W1/BaseApp/Modules/System/JobQueue/JobQueueEntry.Table.al#L593-L647) and [cleanup conditions](https://github.com/microsoft/BCApps/blob/3df81bcd9eff84993c51c80b4c20350665ee1f52/src/Layers/W1/BaseApp/Modules/System/JobQueue/JobQueueEntry.Table.al#L990-L1012)
- [Standard dispatcher: run, reload, and finalize the entry](https://github.com/microsoft/BCApps/blob/3df81bcd9eff84993c51c80b4c20350665ee1f52/src/Layers/W1/BaseApp/Modules/System/JobQueue/JobQueueDispatcher.Codeunit.al#L76-L125)
- [FlowFields and the Exist calculation](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-flowfields)
- [Job Queue Entry fields, including Record ID to Process](https://learn.microsoft.com/en-us/dynamics365/business-central/application/base-application/table/system.threading.job-queue-entry)
