# Day 5 — dbt Foundations

## 1. What is dbt?

dbt (data build tool) is used to transform data inside the warehouse/database using SQL.

It helps turn raw data into tested, modular, version-controlled analytical models.

Core flow:

```text
Raw Data → Staging → Intermediate → Marts
```

---

## 2. dbt Sources

Sources represent raw tables that already exist in the database.

Example:

```sql
from {{ source('raw', 'raw_payments') }}
```

Our raw PostgreSQL tables:

* `raw_customers`
* `raw_subscriptions`
* `raw_payments`

Sources are defined in `models/staging/sources.yml`.

---

## 3. Staging Models

Staging models provide the first transformation layer over raw data.

Examples:

* `stg_customers`
* `stg_subscriptions`
* `stg_payments`

Our staging models are materialized as **views**.

Typical staging responsibilities:

* Select required columns
* Rename columns
* Basic cleaning
* Standardize raw data
* Avoid complex business logic

---

## 4. Intermediate Models

Intermediate models contain reusable transformation logic between staging and final business models.

Example:

```text
int_payments_enriched
```

It joins:

```text
stg_payments
    +
stg_customers
    +
stg_subscriptions
```

while maintaining the grain:

> One row per payment.

The model uses:

```sql
{{ ref('stg_payments') }}
{{ ref('stg_customers') }}
{{ ref('stg_subscriptions') }}
```

The intermediate model is currently materialized as a **view**.

---

## 5. Mart Models

Marts are business-facing models designed for analytics and reporting.

Example:

```text
fct_payments
```

The mart currently reads from:

```sql
{{ ref('int_payments_enriched') }}
```

and is materialized as a **table**.

---

## 6. `source()` vs `ref()`

### `source()`

Used when referencing raw/external tables:

```sql
{{ source('raw', 'raw_payments') }}
```

### `ref()`

Used when referencing another dbt model:

```sql
{{ ref('stg_payments') }}
```

`ref()` also tells dbt about the dependency between models.

---

## 7. Materializations

### View

Creates a database view.

```text
dbt model → PostgreSQL VIEW
```

Useful for lightweight staging transformations.

### Table

Creates a physical database table.

```text
dbt model → PostgreSQL TABLE
```

Useful for marts and frequently queried analytical datasets.

### Incremental

Builds the model initially and then processes only new/changed records on subsequent runs.

Useful for large fact/event tables.

### Ephemeral

Does not create a database object. dbt injects the model logic into downstream SQL as a CTE.

Useful for reusable helper transformations.

---

## 8. Current Project Architecture

```text
raw_customers
raw_subscriptions
raw_payments
        │
        ▼
┌─────────────────────────┐
│       STAGING           │
│                         │
│ stg_customers           │
│ stg_subscriptions       │
│ stg_payments            │
│                         │
│ Materialization: VIEW   │
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│      INTERMEDIATE       │
│                         │
│ int_payments_enriched   │
│                         │
│ Materialization: VIEW   │
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│          MART           │
│                         │
│ fct_payments            │
│                         │
│ Materialization: TABLE  │
└─────────────────────────┘
```

---

## 9. Data Quality Testing

Our project currently has:

```text
11 data tests
11 PASS
0 FAIL
```

Tests include:

* `not_null`
* `unique`
* `relationships`
* `accepted_values`

Example:

```yaml
- name: payment_id
  tests:
    - not_null
    - unique
```

Relationships can validate referential integrity:

```yaml
- name: customer_id
  tests:
    - not_null
    - relationships:
        arguments:
          to: ref('stg_customers')
          field: customer_id
```

---

## 10. Key dbt Commands

### Validate project

```bash
dbt parse
```

### Build models

```bash
dbt run
```

### Run data-quality tests

```bash
dbt test
```

### Preview a model

```bash
dbt show --select int_payments_enriched
```

### Debug database connection

```bash
dbt debug
```

---

## 11. Interview Takeaways

### Why use dbt?

dbt provides a modular, version-controlled transformation layer for analytical data.

It provides:

* SQL-based transformations
* Model dependencies
* Testing
* Documentation
* Version control through Git
* Reusable transformations
* Different materialization strategies

### Why use `ref()`?

`ref()` references another dbt model and allows dbt to automatically understand model dependencies and build order.

### Why separate staging, intermediate, and marts?

Separation creates modularity and makes transformations easier to:

* Understand
* Test
* Reuse
* Maintain
* Debug

### View vs Table

A view generally avoids storing a separate physical copy of the transformed data, while a table materializes the transformed result physically in the database.

### What is an incremental model?

An incremental model processes the full dataset during the initial build and then processes only the relevant new or changed records on subsequent runs.

---

## 12. Current Project Status

```text
dbt project configured                  ✓
PostgreSQL connection                   ✓
Sources configured                      ✓
3 staging models                        ✓
1 intermediate model                    ✓
1 mart model                            ✓
View materialization                    ✓
Table materialization                   ✓
Model dependencies using ref()          ✓
Data-quality tests                      ✓
11/11 tests passing                     ✓
```
