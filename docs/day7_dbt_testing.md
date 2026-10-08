# Day 7 — dbt Data Quality & Testing

## Goal

Understand how dbt tests protect data quality and how to create custom business-rule tests.

---

## 1. What are dbt tests?

dbt tests are automated assertions about data quality.

A test passes when there are **zero rows violating the expected condition**.

Conceptually:

```sql
select *
from some_table
where <bad condition>
```

* 0 rows returned → **PASS**
* 1+ rows returned → **FAIL**

---

## 2. Built-in dbt tests

The project uses four standard dbt tests.

### `not_null`

Ensures a required column does not contain NULL values.

Example:

```yaml
- name: payment_id
  tests:
    - not_null
```

### `unique`

Ensures a column does not contain duplicate values.

Example:

```yaml
- name: payment_id
  tests:
    - unique
```

### `accepted_values`

Ensures a column contains only approved values.

Example:

```yaml
- name: payment_status
  tests:
    - accepted_values:
        arguments:
          values: ['paid', 'failed', 'refunded']
```

### `relationships`

Ensures values in one model exist in a related parent model.

Example:

```yaml
- name: customer_id
  tests:
    - relationships:
        arguments:
          to: ref('stg_customers')
          field: customer_id
```

---

## 3. Testing workflow

The project initially had:

```text
11 tests
11 PASS
0 ERROR
```

A duplicate payment was intentionally inserted into `raw_payments`.

The `unique` test then failed:

```text
PASS=10
ERROR=1
```

The duplicate record was removed and the test passed again.

This demonstrated that dbt tests detect actual data-quality problems rather than simply validating configuration.

---

## 4. Custom SQL tests

Built-in tests cannot express every business rule.

Created:

```text
tests/assert_payment_amount_non_negative.sql
```

SQL:

```sql
select
    payment_id,
    amount
from {{ ref('stg_payments') }}
where amount < 0
```

Business rule:

> Payment amounts should never be negative.

The test passed when no negative payments existed.

A negative payment was intentionally inserted to verify the test.

The test then failed:

```text
Got 1 result, configured to fail if != 0
```

The invalid record was removed and the test passed again.

---

## 5. Cross-model data integrity

Added a relationship test:

```text
stg_payments.subscription_id
        ↓
stg_subscriptions.subscription_id
```

This ensures every payment references an existing subscription.

The payment model now validates relationships to both:

```text
stg_customers
stg_subscriptions
```

---

## 6. Where tests belong

A typical dbt testing structure is:

```text
RAW
 ↓
STAGING
 ├── not_null
 ├── unique
 ├── relationships
 └── accepted_values
 ↓
INTERMEDIATE
 └── transformation/business logic tests
 ↓
MARTS
 └── KPI and business metric validation
```

Staging tests establish basic data integrity.

Intermediate and mart tests can validate more complex business logic.

---

## 7. Built-in vs custom tests

Use built-in tests when the rule matches a standard integrity constraint:

* uniqueness
* required values
* accepted values
* relationships

Use custom SQL tests when the rule requires business-specific logic.

Example:

```sql
where amount < 0
```

---

## 8. Current project status

Day 7 testing work completed:

* 14 total data tests
* Built-in schema tests
* Custom SQL business-rule test
* Payment → customer relationship
* Payment → subscription relationship
* Intentionally failed tests and fixed the underlying data
* Final validation: **12/12 selected tests passing**
* Full test suite restored to a clean state

---

## Interview takeaways

### What are dbt tests?

> dbt tests are automated assertions that validate assumptions about data. A test passes when zero violating rows are returned.

### How does a dbt test fail?

> The test query identifies rows that violate the expected condition. If the query returns one or more rows, dbt marks the test as failed.

### When would you use a custom test?

> When the business rule cannot be expressed cleanly using built-in tests such as `unique`, `not_null`, `accepted_values`, or `relationships`.

### Where should tests be applied?

> Basic integrity tests usually belong in staging, while transformation and business-rule tests can be applied to intermediate models and marts.

### Why are tests important in analytics engineering?

> They provide automated data-quality checks so downstream dashboards, reports, and metrics are less likely to rely on incorrect data.

---

## Commands practiced

```bash
dbt test
dbt test --select stg_payments
dbt test --select assert_payment_amount_non_negative
```

---

## Day 7 outcome

Learned how to:

* Use built-in dbt tests
* Interpret dbt test failures
* Debug failing tests
* Write custom SQL tests
* Test relationships between models
* Validate business rules
* Decide between built-in and custom tests
