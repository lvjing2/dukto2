# Batch transfers and history

English | [简体中文](../batch-and-history.md)

## Sending batches

The system picker supports up to 1000 regular files at once. Review their order, count, size and manifest; remove items or select again before sending. Cancelling the picker preserves the existing selection.

The receiver approves the displayed manifest once. Files are transferred, checked and saved sequentially. Cancellation or any failure stops remaining files, while completed files remain saved. Continue processes unfinished items with fresh consent; changing the target resets sending state.

Authorization is bound to the source address, random token and exact manifest. Additional files, reordering, replay, type changes and size substitutions are rejected. Approval waits up to five minutes; after approval, an inter-file idle gap of two minutes expires the grant. Completion, cancellation or restart invalidates authorization. See [protocol v1](protocol-v1.md).

The queue lives only for the current app session. There are no folder transfers, persisted queues or resumable transfers. Peers without batch capability are asked to update.

## Recent transfers

- Retain the last 100 entries; filtering by historical device name shows up to 20, including offline devices.
- Name and size are the primary information, followed by direction / result and device.
- Wide layouts place completion time and duration separately on the right; narrow layouts and large text allow reflow.
- Each row has one action: view text or open the file's folder. Copying belongs in text details; unavailable file locations disable the folder action.

Completion uses local time: today, yesterday or a date, including the year when needed. Duration uses a monotonic clock from payload transfer through verified commit, excluding approval wait. Subsecond transfers display less than one second. Old entries without a recorded duration are not assigned a guessed value.
