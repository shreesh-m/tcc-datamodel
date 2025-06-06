
USE DATABASE TCC_ASSIGNMENT;
USE SCHEMA SALES;
USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE STORAGE INTEGRATION S3_TCC_INTEGRATION
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::962460829460:role/SnowflakeS3Access-tcctrial-Role'
  STORAGE_ALLOWED_LOCATIONS = ('s3://tcctrialbucket/')
  COMMENT = 'Storage integration for TCC Trial project S3 access';

CREATE OR REPLACE FILE FORMAT csv_format
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    NULL_IF = ('NULL', 'null', '')
    EMPTY_FIELD_AS_NULL = TRUE
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    TRIM_SPACE = TRUE
    ENCODING = 'UTF8';

CREATE OR REPLACE STAGE S3_TCC_STAGE
    URL = 's3://tcctrialbucket/'
    STORAGE_INTEGRATION = S3_TCC_INTEGRATION
    FILE_FORMAT = csv_format;