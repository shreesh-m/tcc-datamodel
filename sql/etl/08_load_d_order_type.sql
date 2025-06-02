USE DATABASE TCC_ASSIGNMENT;
USE SCHEMA BI_LAYER;


MERGE INTO D_ORDER_TYPE d_ot
USING (
    SELECT DISTINCT order_type
    FROM SALES.STG_ORDERS
    WHERE order_type IS NOT NULL AND TRIM(order_type) != ''
) AS s_ot
ON d_ot.order_type_name = s_ot.order_type

WHEN NOT MATCHED THEN
    INSERT (order_type_name)
    VALUES (s_ot.order_type);


MERGE INTO D_ORDER_TYPE AS target
USING (SELECT 0 AS key, 'Unknown' AS name) AS source
ON target.order_type_sk = source.key
WHEN NOT MATCHED THEN
    INSERT (order_type_sk, order_type_name) VALUES (source.key, source.name)
WHEN MATCHED AND target.order_type_name != source.name THEN 
    UPDATE SET target.order_type_name = source.name;