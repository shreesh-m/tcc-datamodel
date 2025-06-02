USE DATABASE TCC_ASSIGNMENT;
USE SCHEMA BI_LAYER;

--Attributes to track for changes: sku_id, product_name, product_number, variant_name, is_variant, product_state_desc
MERGE INTO D_PRODUCT dp
USING (
    SELECT
        s.product_id AS source_product_id,
        s.sku_id,
        s.created_at AS source_created_at,
        s.updated_at AS source_updated_at,
        s.product_name,
        s.product_number,
        s.variant_name,
        s.is_variant,
        s.product_state_desc,
        s.first_published_at AS source_first_published_at,
        HASH(s.sku_id, s.product_name, s.product_number, s.variant_name, s.is_variant, s.product_state_desc) AS row_hash
    FROM SALES.STG_PRODUCTS s
) AS stg_p
ON dp.source_product_id = stg_p.source_product_id AND dp.is_current = TRUE

--Existing product, attributes changed
WHEN MATCHED AND HASH(dp.sku_id, dp.product_name, dp.product_number, dp.variant_name, dp.is_variant, dp.product_state_desc) != stg_p.row_hash THEN
    UPDATE SET
        dp.is_current = FALSE,
        dp.valid_to = stg_p.source_updated_at
;

--Insert new records and new versions of changed products
INSERT INTO D_PRODUCT (
    source_product_id,
    sku_id,
    product_name,
    product_number,
    variant_name,
    is_variant,
    product_state_desc,
    source_first_published_at,
    source_created_at,
    source_updated_at,
    valid_from,
    valid_to,
    is_current
)
SELECT
    s.product_id,
    s.sku_id,
    s.product_name,
    s.product_number,
    s.variant_name,
    s.is_variant,
    s.product_state_desc,
    s.first_published_at,
    s.created_at, 
    s.updated_at,
    COALESCE(s.updated_at, s.created_at, '1999-12-31 23:59:59.999') AS valid_from,
    '9999-12-31 23:59:59.999'::TIMESTAMP_NTZ,
    TRUE
FROM SALES.STG_PRODUCTS s
WHERE NOT EXISTS ( --Ensure we don't re-insert an already existing identical record
    SELECT 1
    FROM D_PRODUCT dp_check
    WHERE dp_check.source_product_id = s.product_id
      AND dp_check.is_current = TRUE
      AND HASH(dp_check.sku_id, dp_check.product_name, dp_check.product_number, dp_check.variant_name, dp_check.is_variant, dp_check.product_state_desc) =
          HASH(s.sku_id, s.product_name, s.product_number, s.variant_name, s.is_variant, s.product_state_desc)
)
AND ( --Conditions to insert
    EXISTS ( --Updated version of a changed record
        SELECT 1 FROM D_PRODUCT dp_closed
        WHERE dp_closed.source_product_id = s.product_id
          AND dp_closed.is_current = FALSE
          AND dp_closed.valid_to = COALESCE(s.updated_at, CURRENT_TIMESTAMP())
          AND HASH(dp_closed.sku_id, dp_closed.product_name, dp_closed.product_number, dp_closed.variant_name, dp_closed.is_variant, dp_closed.product_state_desc) !=
              HASH(s.sku_id, s.product_name, s.product_number, s.variant_name, s.is_variant, s.product_state_desc)
    )
    OR NOT EXISTS ( --New record
        SELECT 1 FROM D_PRODUCT dp_any_version
        WHERE dp_any_version.source_product_id = s.product_id
    )
);