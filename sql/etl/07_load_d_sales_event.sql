USE DATABASE TCC_ASSIGNMENT;
USE SCHEMA BI_LAYER;


MERGE INTO D_SALES_EVENT d_se
USING (
    SELECT DISTINCT sales_event
    FROM SALES.STG_ORDERS
    WHERE sales_event IS NOT NULL AND TRIM(sales_event) != ''
) AS s_se
ON d_se.sales_event_name = s_se.sales_event

WHEN NOT MATCHED THEN
    INSERT (sales_event_name)
    VALUES (s_se.sales_event);


MERGE INTO D_SALES_EVENT AS target
USING (SELECT 0 AS key, 'Unknown' AS name) AS source
ON target.sales_event_sk = source.key
WHEN NOT MATCHED THEN
    INSERT (sales_event_sk, sales_event_name) VALUES (source.key, source.name)
WHEN MATCHED AND target.sales_event_name != source.name THEN
    UPDATE SET target.sales_event_name = source.name;