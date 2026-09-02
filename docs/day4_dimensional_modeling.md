# Day 4 — Dimensional Data Modeling

## 1. Fact vs Dimension Tables

### Fact Table
Stores measurable business events.

Examples:
- payments
- orders
- rides
- support tickets

Example:
`fct_payments`

Typical measures:
- revenue
- quantity
- discount
- duration
- count

### Dimension Table
Stores descriptive attributes about business entities.

Examples:
- customers
- products
- plans
- countries
- dates

Example:
`dim_customers`

---

## 2. Grain

Grain defines:

> What does one row in the table represent?

Examples:

- `fct_payments` → one row per payment transaction
- `fct_order_items` → one row per product within an order
- `customer_month_metrics` → one row per customer per month
- `ticket_lifecycle` → one row per support ticket

### Interview Tip

Always define grain before:
- designing a fact table
- writing joins
- aggregating metrics

Incorrect grain can cause duplicate rows and inflated metrics.

---

## 3. Join Cardinality

Before joining two tables, identify the relationship.

Common relationships:

- One-to-one
- One-to-many
- Many-to-one
- Many-to-many

Example:

`fct_payments` → `raw_subscriptions`

A payment belongs to one subscription.

Therefore:

```sql
p.subscription_id = s.subscription_id

is safer than joining only on:

p.customer_id = s.customer_id


## 4. Natural Key vs Surrogate Key

### Natural Key

A key coming from the source/business system.

Examples:

customer_id
subscription_id
order_id

### Surrogate Key

A generated analytics key.

Example:

customer_sk

Useful for:

stable analytics joins
integrating multiple source systems
Slowly Changing Dimensions
historical dimension versions

A surrogate key can be generated using a deterministic hash of source columns.

## 5. Slowly Changing Dimensions
### SCD Type 1

Overwrite the existing value.

History is not preserved.

Use when:

fixing spelling errors
correcting invalid attributes
history does not matter

Example:

Singpore → Singapore

### SCD Type 2

Preserve historical versions by inserting a new row.

Typical columns:

surrogate key
natural/business key
valid_from
valid_to
is_current

Example:

customer_sk	customer_id	country	valid_from	valid_to	is_current
1001	1	India	2026-01-01	2026-12-31	false
1002	1	Singapore	2027-01-01	NULL	true

Use Type 2 when historical reporting matters.

Examples:

customer segment
subscription tier
employee department
sales territory

## 6. Fact Table Types

### Transaction Fact

Grain:
One row per business event.

Examples:

payment transaction
order item
ride
refund

### Periodic Snapshot

Grain:
One row per entity per fixed time period.

Examples:

customer-month MRR
daily inventory balance
monthly account balance

Useful for:

recurring revenue
inventory
balances
cohort reporting

### Accumulating Snapshot

Grain:
One row per business process.

The row is updated as milestones occur.

Examples:

Support ticket:

created
→ assigned
→ first response
→ resolved
→ closed

Order lifecycle:

created
→ packed
→ shipped
→ delivered

## 7. Normalization vs Denormalization

### Normalization

Splits data across related tables.

Benefits:

reduced redundancy
easier updates
better consistency
data integrity

Common in:

transactional databases
operational applications

### Denormalization

Combines useful attributes for easier analytical querying.

Benefits:

fewer joins
simpler dashboards
easier metric development
better usability for analysts

Common in:

data warehouses
analytics marts
BI layers
Interview Summary

Operational systems usually optimize for writes and integrity.

Analytics systems usually optimize for reads and aggregations.

## 8. Star Schema vs Snowflake Schema

### Star Schema

Fact table in the center with denormalized dimensions around it.

Example:

              dim_customer
                    |
dim_date ---- fct_payments ---- dim_plan
                    |
               dim_country

Advantages:

fewer joins
easier for analysts
simpler BI queries
intuitive structure

### Snowflake Schema

Dimensions are normalized into additional tables.

Example:

dim_country
     |
dim_customer
     |
fct_payments

Advantages:

reduced redundancy
centralized hierarchical attributes

Trade-off:

more joins
more complexity for analysts


## Interview Questions
>Q1. What is the grain of a table?

Grain defines what one individual row represents.

For example:

fct_payments might have a grain of one row per payment transaction.

It should be defined before designing joins and aggregations because inconsistent grain can cause duplicate records and inflated metrics.

>Q2. What is the difference between a fact and dimension table?

Fact tables contain measurable business events such as payments or orders.

Dimension tables contain descriptive information about those events, such as customer, product, plan, or geography.

>Q3. What is the difference between SCD Type 1 and Type 2?

Type 1 overwrites the existing value and does not maintain history.

Type 2 preserves history by creating a new row for every meaningful change and generally uses effective dates, a current-record flag, and a surrogate key.

>Q4. Why use surrogate keys?

Surrogate keys provide a warehouse-controlled identifier that is independent of source systems.

They are especially useful when:

integrating multiple systems
source identifiers can change
maintaining SCD Type 2 history

>Q5. What are the main types of fact tables?
Transaction fact — one row per event
Periodic snapshot — one row per entity per time period
Accumulating snapshot — one row per process lifecycle

>Q6. Star schema vs snowflake schema?

A star schema uses relatively denormalized dimensions directly connected to a fact table.

A snowflake schema normalizes dimensions into additional related tables.

Star schemas are generally simpler for BI and analytical querying.

>Q7. Why are analytical models often denormalized?

Because analytical workloads prioritize read performance, aggregation, and ease of use.

Denormalization reduces the number of joins needed by downstream analysts and BI tools.

>Q8. What can go wrong when joining tables at different grains?

You can create row multiplication.

For example, if one customer has three payments and two subscriptions, joining payments and subscriptions only by customer_id can create:

3 × 2 = 6 rows

This can inflate revenue and other measures.

Always understand grain and join cardinality before joining tables.

## Day 4 Interview Cheat Sheet

Remember these five sentences:

Always define the grain before building a model.
Fact tables represent business events; dimensions describe those events.
SCD Type 1 overwrites history; Type 2 preserves history.
Analytics systems commonly use intentional denormalization for easier querying.
Before every join, validate the cardinality to avoid duplicating facts.