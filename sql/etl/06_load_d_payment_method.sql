USE DATABASE TCC_ASSIGNMENT;
USE SCHEMA BI_LAYER;


MERGE INTO D_PAYMENT_METHOD d_pm
USING (
    SELECT DISTINCT payment_method
    FROM SALES.STG_ORDERS
    WHERE payment_method IS NOT NULL AND TRIM(payment_method) != ''
) AS s_pm
ON d_pm.payment_method_name = s_pm.payment_method

WHEN NOT MATCHED THEN
    INSERT (payment_method_name)
    VALUES (s_pm.payment_method);


MERGE INTO D_PAYMENT_METHOD AS target
USING (SELECT 0 AS key, 'Unknown' AS name) AS source
ON target.payment_method_sk = source.key
WHEN NOT MATCHED THEN
    INSERT (payment_method_sk, payment_method_name) VALUES (source.key, source.name)
WHEN MATCHED AND target.payment_method_name != source.name THEN
    UPDATE SET target.payment_method_name = source.name;