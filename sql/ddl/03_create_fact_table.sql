USE DATABASE TCC_ASSIGNMENT;
USE SCHEMA BI_LAYER;

CREATE OR REPLACE TABLE F_ORDERS (
    order_line_item_sk BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id VARCHAR,                       
    order_number VARCHAR,                  
    order_pos_id VARCHAR,
    dwh_load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),                   
    customer_sk INT,
    product_sk INT,
    shop_sk INT,
    order_created_date_id INT,
    order_delivery_date_id INT, 
    booking_date_id INT,
    order_type_sk VARCHAR,                   
    payment_method_sk VARCHAR,                
    sales_event_sk VARCHAR,                   
    product_unit VARCHAR,         
    quantity NUMBER,
    price_per_unit DECIMAL(20,4),           
    line_total_amount DECIMAL(20,4)              
);