# Day 6 — dbt Incremental Models

## 1. What is an Incremental Model?

A dbt incremental model processes only new or changed records instead of rebuilding the entire target table on every run.

This is useful for large fact tables where rebuilding all historical data would be expensive and slow.

### Basic pattern

```sql
{{ config(
    materialized='incremental',
    unique_key='payment_id'
) }}

select
    ...
from {{ ref('int_payments_enriched') }}

{% if is_incremental() %}
    where payment_date >= (
        select max(payment_date)
        from {{ this }}
    )
{% endif %}
```

---

## 2. First Run vs Subsequent Runs

### First run

The target table does not exist yet.

dbt processes the full dataset and creates the table.

In our project:

```text
6 existing payment records
        ↓
incremental model
        ↓
6 rows created
```

### Subsequent run with a new record

A new payment (`1007`) was added to the raw source.

dbt processed only the new record:

```text
INSERT 0 1
```

The target table increased from 6 → 7 rows.

---

## 3. `is_incremental()`

`is_incremental()` allows us to apply SQL logic only when the model is already built and dbt is performing an incremental run.

Conceptually:

```text
First run
    ↓
Full dataset

Later runs
    ↓
Incremental filter
    ↓
New / changed records
```

---

## 4. `unique_key`

The `unique_key` tells dbt how to identify an existing record.

Our model uses:

```sql
unique_key='payment_id'
```

Therefore `payment_id` is treated as the unique identifier for payment records.

This is important when existing records can change.

---

## 5. Important Experiment — Existing Record Update

We initially used:

```sql
where payment_date > (
    select max(payment_date)
    from {{ this }}
)
```

Payment `1007` had:

```text
payment_date = 2026-04-15
payment_status = paid
```

The source record was then changed to:

```text
payment_status = refunded
```

However, the incremental model did not update it.

### Why?

The target table already had:

```text
max(payment_date) = 2026-04-15
```

The condition became:

```text
2026-04-15 > 2026-04-15
```

which is false.

Therefore payment `1007` was never selected for processing.

### Lesson

A `unique_key` cannot update a record that the incremental filter excludes.

---

## 6. Fix

We changed the condition to:

```sql
where payment_date >= (
    select max(payment_date)
    from {{ this }}
)
```

Now records from the latest date are reconsidered.

Because `payment_id` is the `unique_key`, dbt can identify payment `1007` as an existing record and update it.

Result:

```text
Before:
payment 1007 → paid

Source:
payment 1007 → refunded

After incremental run:
payment 1007 → refunded
```

The row count remained:

```text
7
```

instead of creating a duplicate.

---

## 7. Important Production Consideration

Using `>=` is useful for demonstrating the concept, but real production pipelines need to consider:

* Late-arriving records
* Updates to older records
* Reliable `updated_at` or ingestion timestamps
* Lookback windows
* Deduplication
* Correct `unique_key` selection

A common strategy is to reprocess a small historical window rather than only looking for strictly new records.

Example:

```sql
where payment_date >= (
    select max(payment_date) - interval '2 days'
    from {{ this }}
)
```

The exact strategy depends on the source system and data-arrival behavior.

---

## 8. Key Commands

```bash
dbt parse
dbt ls --select fct_payments_incremental
dbt run --select fct_payments_incremental
```

---

## 9. Interview Takeaways

### What is an incremental model?

A dbt model that processes only new or changed data instead of rebuilding the entire target table.

### Why use incremental models?

To reduce:

* Processing time
* Warehouse compute
* Cost
* Full-table rebuilds

### What does `is_incremental()` do?

It allows different SQL logic to run during incremental execution versus the initial/full build.

### What does `unique_key` do?

It identifies the logical key of a record so dbt can update an existing record instead of creating a duplicate.

### Is `unique_key` enough to handle updates?

No.

The incremental filter must first select the record. If the filter excludes an updated record, the `unique_key` cannot help.

### What is a major challenge with incremental models?

Handling late-arriving or updated records correctly.

---

## 10. Project Status

Day 6 completed:

* Created `fct_payments_incremental`
* Built initial incremental table
* Loaded 6 historical records
* Added a new payment and processed only 1 record
* Tested an existing record update
* Demonstrated the importance of `unique_key`
* Identified the limitation of a simple incremental filter
* Updated the filter to handle records on the latest date
* Verified the row count remained 7 after the update
