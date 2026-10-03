---
bc-version: [all]
domain: ui
keywords: [notification, recall, notification-id, createguid, notification-lifecycle-mgt, sendnotification, sendnotificationwithadditionalcontext, recallnotificationsforrecord, handledelayedinsert, notification-context]
technologies: [al]
countries: [w1]
application-area: [all]
---

# A notification that must be recalled needs an Id the code can find again

## Description

`Notification.Recall()` withdraws the notification whose `Id` it carries. When `Id` is left unassigned, `Send()` assigns one. A later `Recall()` on a new `Notification` variable has no way to name that Id, so a warning sent that way cannot be withdrawn when its condition clears. It stays until the user dismisses it or the page instance closes. Microsoft Learn's own `Id`/`Recall` example uses a predefined Id "so that the notification can be recalled", and the Recall page states that a notification "can be recalled successfully even if it hasn't been sent". Base App relies on that: it assigns a fixed Id and calls `Recall()` before every send.

Which Id is right depends on how many instances must be visible at the same time:

- **One at a time**, even when the warning is about different records: a fixed GUID, returned from a procedure or assigned as a literal, recalled before each send. `Analysis View.ShowResetNeededNotification` does this with plain `Send()`. `Sales Line.SendBlockedItemNotification` does it for line records, passing the fixed Id to `"Notification Lifecycle Mgt.".SendNotification`, which keeps an Id that is already set. Showing only the latest line's warning is a deliberate design choice there, not a defect. Learn does not document what `Send()` does when a notification with the same Id is already displayed, so recall first rather than relying on `Send()` to replace it.
- **Several records' notifications visible at the same time** (for example one availability warning per document line): one fixed Id cannot tell them apart. Use codeunit 1511 `"Notification Lifecycle Mgt."`. `SendNotification(Notification, RecId)` assigns `CreateGuid()` when `Id` is null, sends, and stores the Id against the `RecordId` in the temporary table `"Notification Context"`. `RecallNotificationsForRecord(RecId, HandleDelayedInsert)` recalls every tracked notification for that record. When one record can carry several independent warnings, pass a fixed GUID per reason to `SendNotificationWithAdditionalContext` and `RecallNotificationsForRecordWithAdditionalContext`. `Item-Check Avail.` does this: a `CreateGuid()` Id per notification, its fixed availability GUID as the additional context.

## Best Practice

Assign a fixed `Id` to any notification that the same code can also withdraw while only one instance needs to be visible, and recall it with that Id before re-sending updated content. See sample: [`notification-recall-needs-known-id.good.al`](notification-recall-needs-known-id.good.al).

When notifications for several records must be visible together, send and recall through `"Notification Lifecycle Mgt."` instead of calling `Send()`/`Recall()` directly. The codeunit is `SingleInstance`, so tracking lasts for the session. While a record does not exist yet, its notification is stored under the table's empty `RecordId`. Pass `HandleDelayedInsert = true` when recalling for a record that may not be inserted yet, and `false` when recalling after the record is deleted, as Base App's own delete subscribers do. Base App's `"Notification Lifecycle Handler"` (codeunit 1508) moves tracked notifications on insert and rename, and recalls them on delete, only for the Base App tables it subscribes to, such as `Sales Line`. For another table, call `SetRecordID`, `UpdateRecordID`, and `RecallNotificationsForRecord` from that table's own insert, rename, and delete paths.

## Anti Pattern

Code that both sends and recalls a notification, for example `Send()` when a condition holds and `Recall()` in the `else` branch or when the condition clears, but never assigns `Id`, or assigns a fresh `CreateGuid()` and calls `Send()`/`Recall()` directly. The `Recall()` cannot reach the notification that was sent. The per-record form: notifications for several records must be visible at the same time, but they share one fixed Id sent and recalled directly, so recalling one record's warning cannot leave the others in place. See sample: [`notification-recall-needs-known-id.bad.al`](notification-recall-needs-known-id.bad.al).

Not this pattern:

- A one-off informational notification that the code never recalls. Learn's own Sales Order example sends without an Id.
- A notification sent through `"Notification Lifecycle Mgt."` without an Id, because the codeunit assigns and tracks one.
- A fixed Id shared across records when one warning at a time is intended, recalled before re-send, with or without `SendNotification`, as in `Sales Line`'s blocked-item notification or `Over-Receipt Mgt.`.

## References

- [Notification.Id method](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/notification/notification-id-method): an unassigned Id is assigned at `Send()`; the example sets a predefined Id so the notification can be recalled.
- [Notification.Recall method](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/notification/notification-recall-method): a notification can be recalled more than once, and before it is sent. The same page lists client communication failure, or recalling a notification with no instance, as reasons `Recall()` can return `false`, and an uncaptured failure is a runtime error. Base App's unconditional recall-before-send (Analysis View, Sales Line) shows that recalling a fixed Id with nothing on screen is safe in practice.
- [Using nonintrusive notifications](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-notifications-developing): notifications remain for the page instance or until dismissed.
- [NotificationLifecycleMgt.Codeunit.al](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Layers/W1/BaseApp/Modules/System/Notifications/NotificationLifecycleMgt.Codeunit.al): `SendNotification` and `SendNotificationWithAdditionalContext` (lines 17-36), `RecallNotificationsForRecord` (38-44), `GetUsableRecordId` (177-191). [NotificationLifecycleHandler.Codeunit.al](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Layers/W1/BaseApp/System/Notifications/NotificationLifecycleHandler.Codeunit.al): `Sales Line` insert, rename, and delete subscribers (lines 27-52).
- Base App usage: [AnalysisView.Table.al](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Layers/W1/BaseApp/Finance/Analysis/AnalysisView.Table.al) (`ShowResetNeededNotification`, lines 1039-1051), [SalesLine.Table.al](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Layers/W1/BaseApp/Sales/Document/SalesLine.Table.al) (`SendBlockedItemNotification`, lines 10126-10135), [OverReceiptMgt.Codeunit.al](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Layers/W1/BaseApp/Purchases/Document/OverReceiptMgt.Codeunit.al) (lines 212-228), and [ItemCheckAvail.Codeunit.al](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Layers/W1/BaseApp/Inventory/Availability/ItemCheckAvail.Codeunit.al) (recall at lines 89-90, `CreateGuid()` Id and send at 636-646).
