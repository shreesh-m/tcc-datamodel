USE DATABASE TCC_ASSIGNMENT;
USE SCHEMA BI_LAYER;

SET START_DATE = '2000-01-01'::DATE; 
SET END_DATE = '2025-12-31'::DATE; 

INSERT OVERWRITE INTO D_DATE (
    date_id,
    full_date,
    year,
    quarter,
    month,
    month_name,
    day,
    day_of_week_num,
    day_of_week_name,
    week_of_year,
    day_of_year
)
SELECT
    TO_NUMBER(TO_VARCHAR(generated_date.date_val, 'YYYYMMDD')) AS date_id,
    generated_date.date_val AS full_date,
    YEAR(generated_date.date_val) AS year,
    QUARTER(generated_date.date_val) AS quarter,
    MONTH(generated_date.date_val) AS month,
    MONTHNAME(generated_date.date_val) AS month_name,
    DAY(generated_date.date_val) AS day,
    DAYOFWEEKISO(generated_date.date_val) % 7 AS day_of_week_num, 
    DECODE(DAYOFWEEKISO(generated_date.date_val),
        1, 'Monday', 2, 'Tuesday', 3, 'Wednesday', 4, 'Thursday',
        5, 'Friday', 6, 'Saturday', 7, 'Sunday'
    ) AS day_of_week_name,
    WEEKOFYEAR(generated_date.date_val) AS week_of_year,
    DAYOFYEAR(generated_date.date_val) AS day_of_year
FROM (
    SELECT
        DATEADD(DAY, SEQ4(), $START_DATE) AS date_val
    FROM
        TABLE(GENERATOR(ROWCOUNT => 10000)) 
) AS generated_date
WHERE
    generated_date.date_val >= $START_DATE AND generated_date.date_val <= $END_DATE;