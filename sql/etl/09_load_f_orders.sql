USE DATABASE TCC_ASSIGNMENT;
USE SCHEMA BI_LAYER;

--Full truncate and load.
TRUNCATE TABLE IF EXISTS F_ORDERS;

INSERT INTO F_ORDERS(
    order_id,
    order_number,
    order_pos_id,
    customer_sk,
    product_sk,
    shop_sk,
    order_created_date_id,
    order_delivery_date_id, 
    booking_date_id,       
    order_type_sk,
    payment_method_sk,
    sales_event_sk,
    product_unit,
    quantity,
    price_per_unit,
    line_total_amount,
    dwh_load_timestamp
)
SELECT
    so.order_id,
    so.order_number,
    sop.order_pos_id,
    dc.customer_sk,
    dp.product_sk,
    dsh.shop_sk,
    TO_NUMBER(TO_VARCHAR(TO_DATE(so.order_date), 'YYYYMMDD')) AS order_created_date_id,
    CASE
        WHEN so.delivery_date IS NOT NULL THEN TO_NUMBER(TO_VARCHAR(TO_DATE(so.delivery_date), 'YYYYMMDD'))
        ELSE NULL
    END AS order_delivery_date_id,
    CASE
        WHEN so.booking_date IS NOT NULL THEN TO_NUMBER(TO_VARCHAR(TO_DATE(so.booking_date), 'YYYYMMDD'))
        ELSE NULL
    END AS booking_date_id,
    dot.order_type_sk,
    dpay.payment_method_sk,
    dse.sales_event_sk,
    sop.product_unit,
    sop.quantity,
    sop.price AS price_per_unit,
    sop.quantity * sop.price AS line_total_amount,
    CURRENT_TIMESTAMP() AS dwh_load_timestamp
FROM SALES.STG_ORDERS so
JOIN SALES.STG_ORDER_POSITIONS sop ON so.order_id = sop.order_id
  LEFT JOIN D_CUSTOMER dc 
    ON so.customer_id = dc.source_customer_id 
   AND TO_DATE(so.order_date) BETWEEN TO_DATE(dc.valid_from) AND TO_DATE(dc.valid_to)
  LEFT JOIN D_PRODUCT dp 
    ON sop.product_id = dp.source_product_id 
   AND TO_DATE(so.order_date) BETWEEN TO_DATE(dp.valid_from) AND TO_DATE(dp.valid_to)
  LEFT JOIN D_SHOP dsh 
    ON so.shop_id = dsh.source_shop_id 
   AND TO_DATE(so.order_date) BETWEEN TO_DATE(dsh.valid_from) AND TO_DATE(dsh.valid_to)
  LEFT JOIN D_ORDER_TYPE dot
    ON so.order_type = dot.order_type_name
  LEFT JOIN D_PAYMENT_METHOD dpay
    ON so.payment_method = dpay.payment_method_name
  LEFT JOIN D_SALES_EVENT dse
    ON so.sales_event = dse.sales_event_name
;