USE DATABASE TCC_ASSIGNMENT;
USE SCHEMA BI_LAYER;

--Attributes to track for changes: name (shop), platform, locale, shop_locale, platform_type
MERGE INTO D_SHOP dsh
USING (
    SELECT
        s.shop_id AS source_shop_id,
        s.shop AS name,
        s.platform,
        s.locale,
        s.shop_locale,
        s.platform_type,
        HASH(s.shop, s.platform, s.locale, s.shop_locale, s.platform_type) AS row_hash
    FROM SALES.STG_SHOPS s
) AS stg_s
ON dsh.source_shop_id = stg_s.source_shop_id AND dsh.is_current = TRUE

--Existing shop, attributes changed
WHEN MATCHED AND HASH(dsh.name, dsh.platform, dsh.locale, dsh.shop_locale, dsh.platform_type) != stg_s.row_hash THEN
    UPDATE SET
        dsh.is_current = FALSE,
        dsh.valid_to = CURRENT_TIMESTAMP() 
;

--Insert new records and new versions of changed shops
INSERT INTO D_SHOP (
    source_shop_id,
    name,
    platform,
    locale,
    shop_locale,
    platform_type,
    valid_from,
    valid_to,
    is_current
)
SELECT
    s.shop_id,
    s.shop,
    s.platform,
    s.locale,
    s.shop_locale,
    s.platform_type,
    '1999-12-31 23:59:59.999'::TIMESTAMP_NTZ,
    '9999-12-31 23:59:59.999'::TIMESTAMP_NTZ,
    TRUE
FROM SALES.STG_SHOPS s
WHERE NOT EXISTS ( --Ensure we don't re-insert an already current identical record
    SELECT 1
    FROM D_SHOP dsh_check
    WHERE dsh_check.source_shop_id = s.shop_id
      AND dsh_check.is_current = TRUE
      AND HASH(dsh_check.name, dsh_check.platform, dsh_check.locale, dsh_check.shop_locale, dsh_check.platform_type) =
          HASH(s.shop, s.platform, s.locale, s.shop_locale, s.platform_type)
)
AND ( --Condition to insert:
    EXISTS ( --Updated version of a changed record
        SELECT 1 FROM D_SHOP dsh_closed
        WHERE dsh_closed.source_shop_id = s.shop_id
          AND dsh_closed.is_current = FALSE
          AND dsh_closed.valid_to = CURRENT_TIMESTAMP()
          AND HASH(dsh_closed.name, dsh_closed.platform, dsh_closed.locale, dsh_closed.shop_locale, dsh_closed.platform_type) !=
              HASH(s.shop, s.platform, s.locale, s.shop_locale, s.platform_type)
    )
    OR NOT EXISTS ( --New shop to D_SHOP
        SELECT 1 FROM D_SHOP dsh_any_version
        WHERE dsh_any_version.source_shop_id = s.shop_id
    )
);