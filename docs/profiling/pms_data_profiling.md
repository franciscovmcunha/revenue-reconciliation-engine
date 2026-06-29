# PMS Data Profiling

## Overview

The PMS dataset represents invoice-level transactional data exported directly from the Property Management System (PMS). This dataset serves as the primary accounting source for revenue reconciliation and provides the commercial reference against which payment providers and cash register transactions will be reconciled.

---

## Dataset Summary

| Metric | Value                    |
|--------|--------------------------|
| Source | PMS CSV Export           |
| Files  | 2                        |
| Rows   | 618                      |
| Columns| 31                       |
| Period | 2026-01-01 to 2026-05-31 |

The dataset covers the complete invoicing activity between January and May 2026.

---

## Schema Quality

The dataset presents a stable and consistent schema across all imported files.

All expected columns were successfully identified during ingestion and no schema inconsistencies were detected between exports.

Column names were standardized to snake_case during the parsing stage while preserving the original business meaning.

---

## Completeness

Null values are present across several columns.

However, missing values are concentrated almost exclusively in optional business attributes such as:

- voucher
- external references
- fiscal signature number
- card information

Mandatory operational fields present complete coverage, including:

- document_number
- document_type
- invoice_date
- gross_amount
- payment_method

No critical business attribute presented significant completeness issues.

---

## Uniqueness

The **document_number** column presents complete uniqueness across the entire dataset.

Although multiple invoices may belong to the same customer (invoice_holder), every invoice possesses a unique identifier.

This confirms **document_number** as the natural primary key for the PMS dataset.

No duplicate invoice identifiers were detected.

---

## Business Distribution

Business profiling identified:

- 4 document types
- Multiple payment methods
- Single operating currency (EUR)
- Consistent invoice issuance throughout the analysed period

No unexpected business categories were identified.

---

## Data Consistency

Several consistency validations were performed, including:

- Gross amount ≥ Net amount
- Valid invoice dates
- Valid payment methods
- Currency validation
- Mandatory identifiers

No inconsistencies were identified.

Amounts, payment information and invoice metadata remain internally consistent across all analysed records.

---

## Cardinality Analysis

Cardinality analysis confirms:

- document_number → Unique identifier
- reservation_number → One reservation may generate multiple invoices
- invoice_holder → Multiple invoices per customer

The resulting relationships are consistent with expected PMS business behaviour.

---

## Overall Assessment

The PMS dataset demonstrates a high level of technical quality.

Main observations:

- Complete primary key coverage
- No duplicate invoices
- Stable schema
- Consistent business rules
- Missing values restricted to optional business fields

The dataset is considered suitable for the Bronze layer and subsequent reconciliation modelling.
