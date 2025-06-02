USE DATABASE TCC_ASSIGNMENT;
USE SCHEMA BI_LAYER;


CREATE TABLE IF NOT EXISTS D_DATE (
    date_id INT PRIMARY KEY,
    full_date DATE,
    year INT,
    quarter INT,
    month INT,
    month_name VARCHAR(10),
    day INT,
    day_of_week_num INT,
    day_of_week_name VARCHAR(10),
    week_of_year INT,
    day_of_year INT
);

CREATE TABLE IF NOT EXISTS D_CUSTOMER (
    customer_sk INT IDENTITY(1,1) PRIMARY KEY,
    source_customer_id VARCHAR,
    address_hash_id VARCHAR,
    country VARCHAR,
    currency_unit VARCHAR,
    tax_eucountry VARCHAR,
    source_created_at TIMESTAMP_NTZ,
    source_updated_at TIMESTAMP_NTZ,
    valid_from TIMESTAMP_NTZ,
    valid_to TIMESTAMP_NTZ,
    is_current BOOLEAN
);

CREATE TABLE IF NOT EXISTS D_PRODUCT (
    product_sk INT IDENTITY(1,1) PRIMARY KEY,
    source_product_id VARCHAR,
    sku_id VARCHAR,
    product_name VARCHAR,
    product_number VARCHAR,
    variant_name VARCHAR,
    is_variant VARCHAR,
    product_state_desc VARCHAR,
    source_first_published_at TIMESTAMP_NTZ,
    source_created_at TIMESTAMP_NTZ,
    source_updated_at TIMESTAMP_NTZ,
    valid_from TIMESTAMP_NTZ,
    valid_to TIMESTAMP_NTZ,
    is_current BOOLEAN
);


CREATE TABLE IF NOT EXISTS D_SHOP (
    shop_sk INT IDENTITY(1,1) PRIMARY KEY,
    source_shop_id VARCHAR, 
    name VARCHAR,
    platform VARCHAR,
    locale VARCHAR,
    shop_locale VARCHAR,
    platform_type VARCHAR,
    valid_from TIMESTAMP_NTZ,
    valid_to TIMESTAMP_NTZ,
    is_current BOOLEAN
);

CREATE TABLE IF NOT EXISTS D_ORDER_TYPE (
    order_type_sk INT IDENTITY(1,1) PRIMARY KEY,
    order_type_name VARCHAR UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS D_SALES_EVENT (
    sales_event_sk INT IDENTITY(1,1) PRIMARY KEY,
    sales_event_name VARCHAR UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS D_PAYMENT_METHOD (
    payment_method_sk INT IDENTITY(1,1) PRIMARY KEY,
    payment_method_name VARCHAR UNIQUE NOT NULL
);
