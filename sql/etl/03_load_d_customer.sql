USE DATABASE TCC_ASSIGNMENT;
USE SCHEMA BI_LAYER;

--Attributes to track for changes in the HASH function: address_hash_id, country, currency_unit, tax_eucountry
MERGE INTO D_CUSTOMER dc
USING (
    SELECT
        s.customer_id AS source_customer_id,
        s.address_hash_id,
        s.country,
        s.created_at AS source_created_at, 
        s.updated_at AS source_updated_at, 
        s.currency_unit,
        s.tax_eucountry,
        HASH(s.address_hash_id, s.country, s.currency_unit, s.tax_eucountry) AS row_hash -- Hashing relevant attributes for change detection
    FROM SALES.STG_CUSTOMERS s
) AS stg_c
ON dc.source_customer_id = stg_c.source_customer_id AND dc.is_current = TRUE

--Existing customer, attributes changed
WHEN MATCHED AND HASH(dc.address_hash_id, dc.country, dc.currency_unit, dc.tax_eucountry) != stg_c.row_hash THEN
    UPDATE SET
        dc.is_current = FALSE,
        dc.valid_to = stg_c.source_updated_at 
; 

--Insert new records and new versions of changed customers
INSERT INTO D_CUSTOMER (
    source_customer_id,
    address_hash_id,
    country,
    currency_unit,
    tax_eucountry,
    source_created_at,
    source_updated_at,
    valid_from,
    valid_to,
    is_current
)
SELECT
    s.customer_id,
    s.address_hash_id,
    s.country,
    s.currency_unit,
    s.tax_eucountry,
    s.created_at, 
    s.updated_at, 
    COALESCE(s.updated_at, s.created_at, '1999-12-31 23:59:59.999') AS valid_from,
    '9999-12-31 23:59:59.999'::TIMESTAMP_NTZ,
    TRUE
FROM SALES.STG_CUSTOMERS s
LEFT JOIN D_CUSTOMER dc_old
    ON s.customer_id = dc_old.source_customer_id
    AND dc_old.valid_to = COALESCE(s.updated_at, CURRENT_TIMESTAMP()) 
    AND dc_old.is_current = FALSE                                   
WHERE NOT EXISTS ( --Ensure we don't re-insert an already current identical record
    SELECT 1
    FROM D_CUSTOMER dc_check
    WHERE dc_check.source_customer_id = s.customer_id
      AND dc_check.is_current = TRUE
      AND HASH(dc_check.address_hash_id, dc_check.country, dc_check.currency_unit, dc_check.tax_eucountry) = HASH(s.address_hash_id, s.country, s.currency_unit, s.tax_eucountry)
)
AND ( --Condition to insert:
    EXISTS ( --Updated version of a changed record
        SELECT 1 FROM D_CUSTOMER dc_closed
        WHERE dc_closed.source_customer_id = s.customer_id
          AND dc_closed.is_current = FALSE
          AND dc_closed.valid_to = COALESCE(s.updated_at, CURRENT_TIMESTAMP())
          AND HASH(dc_closed.address_hash_id, dc_closed.country, dc_closed.currency_unit, dc_closed.tax_eucountry) != HASH(s.address_hash_id, s.country, s.currency_unit, s.tax_eucountry)
    )
    OR NOT EXISTS ( --New customer to D_CUSTOMER
        SELECT 1 FROM D_CUSTOMER dc_any_version
        WHERE dc_any_version.source_customer_id = s.customer_id
    )
);