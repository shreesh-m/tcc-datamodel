USE DATABASE TCC_ASSIGNMENT;
USE SCHEMA SALES;

CREATE OR REPLACE TABLE STG_PRODUCTS (
    product_id VARCHAR,
    sku_id VARCHAR,
    updated_at TIMESTAMP_NTZ,
    created_at TIMESTAMP_NTZ,
    product_name VARCHAR,
    product_number VARCHAR,
    variant_name VARCHAR,
    is_variant VARCHAR, 
    product_state_desc VARCHAR,
    first_published_at TIMESTAMP_NTZ
);

CREATE OR REPLACE TABLE STG_SHOPS (
    shop_id VARCHAR,
    shop VARCHAR,
    platform VARCHAR,
    locale VARCHAR,
    shop_locale VARCHAR,
    platform_type VARCHAR
);


CREATE OR REPLACE TABLE STG_ORDERS (
    created_at TIMESTAMP_NTZ,
    updated_at TIMESTAMP_NTZ,
    order_id VARCHAR,
    order_number VARCHAR,
    webshop_order_number VARCHAR,
    sales_event VARCHAR,
    order_type VARCHAR,
    customer_id VARCHAR,
    shop_id VARCHAR,
    payment_method VARCHAR,
    order_date TIMESTAMP_NTZ,
    delivery_date TIMESTAMP_NTZ,
    booking_date TIMESTAMP_NTZ
);


CREATE OR REPLACE TABLE STG_ORDER_POSITIONS (
    created_at TIMESTAMP_NTZ,
    updated_at TIMESTAMP_NTZ,
    order_id VARCHAR,
    order_pos_id VARCHAR,
    product_id VARCHAR,
    product_unit VARCHAR,
    product_name VARCHAR, 
    price DECIMAL(18,4),
    quantity NUMBER
);


CREATE OR REPLACE TABLE STG_CUSTOMERS (
    customer_id VARCHAR,
    address_hash_id VARCHAR,
    country VARCHAR,
    created_at TIMESTAMP_NTZ,
    updated_at TIMESTAMP_NTZ,
    currency_unit VARCHAR,
    tax_eucountry VARCHAR
);