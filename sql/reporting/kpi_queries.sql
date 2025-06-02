--Intake and revenue
SELECT
  s.name AS shop_name,
  s.shop_locale AS shop_locale,
  d_created.year AS year,
  d_created.month AS month,
  d_created.month_name AS month_name,
  SUM(f.line_total_amount) AS total_order_intake,
  SUM(
    CASE
      WHEN f.order_delivery_date_id IS NOT NULL THEN f.line_total_amount
      ELSE 0
    END
  ) AS total_revenue
FROM F_ORDERS f
  LEFT JOIN D_SHOP s 
    ON f.shop_sk = s.shop_sk
  LEFT JOIN D_DATE d_created 
    ON f.order_created_date_id = d_created.date_id
  LEFT JOIN D_DATE d_delivered 
    ON f.order_delivery_date_id = d_delivered.date_id
GROUP BY
  s.name,
  s.shop_locale,
  d_created.year,
  d_created.month,
  d_created.month_name
ORDER BY
  s.name,
  d_created.year,
  d_created.month;

--Intake,revenue and drop-off rate  
SELECT
  s.name AS shop_name,
  s.shop_locale AS shop_locale,
  d_created.year AS year,
  d_created.month AS month,
  d_created.month_name AS month_name,
  SUM(f.line_total_amount) AS order_intake,
  SUM(
    CASE
      WHEN f.order_delivery_date_id IS NOT NULL THEN f.line_total_amount
      ELSE 0
    END
  ) AS revenue,
  CASE
    WHEN SUM(f.line_total_amount) = 0 THEN 0
    ELSE 1 - (
      SUM(
        CASE
          WHEN f.order_delivery_date_id IS NOT NULL THEN f.line_total_amount
          ELSE 0
        END
      ) / SUM(f.line_total_amount)
    )
  END AS drop_off_rate
FROM F_ORDERS f
  JOIN D_SHOP s 
    ON f.shop_sk = s.shop_sk
  JOIN D_DATE d_created 
    ON f.order_created_date_id = d_created.date_id
GROUP BY s.name,
  s.shop_locale,
  d_created.year,
  d_created.month,
  d_created.month_name
ORDER BY
  s.name,
  d_created.year,
  d_created.month;

--Lag time from purchase to shipping
SELECT
  s.name AS shop_name,
  s.shop_locale AS shop_locale,
  AVG(
    DATEDIFF(
      'day',
      d_created.full_date,
      d_delivered.full_date
    )
  ) AS avg_shipping_lag_days
FROM F_ORDERS f
  JOIN D_SHOP s 
    ON f.shop_sk = s.shop_sk
  JOIN D_DATE d_created 
    ON f.order_created_date_id = d_created.date_id
  JOIN D_DATE d_delivered 
    ON f.order_delivery_date_id = d_delivered.date_id
WHERE f.order_delivery_date_id IS NOT NULL
GROUP BY s.name, s.shop_locale
ORDER BY s.name;

--Absolute and relative new and returning
WITH first_order_per_customer AS (
  SELECT
    customer_sk,
    MIN(order_created_date_id) AS first_order_date_id
  FROM F_ORDERS
  GROUP BY customer_sk
),
month_customer_flags AS (
  SELECT
    d.year,
    d.month,
    d.month_name,
    f.customer_sk,
    CASE 
      WHEN f.order_created_date_id = fo.first_order_date_id 
      THEN 'NEW' 
      ELSE 'RETURNING' 
    END                           AS customer_type
  FROM F_ORDERS f
  JOIN first_order_per_customer fo 
    ON f.customer_sk = fo.customer_sk
  JOIN D_DATE d 
    ON f.order_created_date_id = d.date_id
)
SELECT
  year,
  month,
  month_name,

  --Counts
  COUNT(DISTINCT CASE WHEN customer_type = 'NEW' THEN customer_sk END)        AS new_customers,
  COUNT(DISTINCT CASE WHEN customer_type = 'RETURNING' THEN customer_sk END)  AS returning_customers,
  COUNT(DISTINCT customer_sk)                                                 AS total_customers,

  --Percentages
  ROUND(
    100.0 * COUNT(DISTINCT CASE WHEN customer_type = 'NEW' THEN customer_sk END)
    / NULLIF(COUNT(DISTINCT customer_sk), 0),
    2)                                                                            AS pct_new,
  ROUND(
    100.0 * COUNT(DISTINCT CASE WHEN customer_type = 'RETURNING' THEN customer_sk END)
    / NULLIF(COUNT(DISTINCT customer_sk), 0),
    2)                                                                            AS pct_returning

FROM month_customer_flags
GROUP BY year, month, month_name
ORDER BY year, month;

