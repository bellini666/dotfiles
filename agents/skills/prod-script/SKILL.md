---
name: prod-script
description: This skill should be used when writing a script that reads or repairs production data, such as a Django shell audit, backfill, reconciliation, or diagnostic against a live API or database.
---

# Production Script

An empty or partial result must never look like a clean one.

## Audit first

Write a read-only audit. Write the repair only after I confirm the audit output.

- Handle expected API and validation errors per record: record the failure and continue.
- End with counts: scanned, skipped, failed, affected.
- Treat zero scanned, or an unexpectedly empty query, as a failure and exit non-zero.
- Print a few sample records, so I can check the verdict by eye.
- Walk each verdict against one known-good and one known-bad record before trusting it. Check date logic for future dates and restarts.

## Repair

- Dry run by default. Applying takes an explicit flag.
- Print the record and intended change for each write in dry run, and the actual result when applying.
- Make it safe to re-run: skip records already repaired.
- Per-object saves unless bulk writes are verified safe: bulk writes bypass `save()`, signals, and audit history.

## Delivery

- Django: a Python script for the Django shell, never raw SQL.
- Hand over the script and the exact command. Running it in production needs a yes for that specific run.
