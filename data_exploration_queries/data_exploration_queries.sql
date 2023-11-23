-- Cleansed dim_calendar Table --
SELECT
  *
from
  `portfolio-e`.dim_calendar;

alter table
  dim_calendar rename column FullDateAlternateKey to date,
  rename column EnglishDayNameOfWeek to day,
  rename column EnglishMonthName to month,
  rename column MonthNumberOfYear to month_no,
  rename column CalendarQuarter to quarter,
  rename column CalendarYear to year;

SELECT
  datekey,
  date,
  day,
  month,
  month_no,
  quarter,
  year
from
  `portfolio-e`.dim_calendar;

create table `portfolio-e`.dim_calendar_exploration as
SELECT
  datekey,
  date,
  day,
  month,
  month_no,
  quarter,
  year
from
  `portfolio-e`.dim_calendar;

-- Cleansed dim_customers Table --
SELECT
  *
from
  `portfolio-e`.dim_customers;

alter table
  dim_customers rename column customerkey to customer_key,
  rename column firstname to first_name,
  rename column lastname to last_name,
  rename column datefirstpurchase to date_first_purchase;

create table `portfolio-e`.dim_customers_exploration as
SELECT
  c.customer_key,
  c.first_name,
  c.last_name,
  concat(c.first_name, ' ', c.last_name) as full_name,
  CASE
    c.gender
    WHEN 'M' THEN 'Male'
    WHEN 'F' THEN 'Female'
  END AS gender,
  c.date_first_purchase,
  g.city as customer_city
from
  `portfolio-e`.dim_customers c
  left join `portfolio-e`.`dim-geography` g on c.geographykey = g.geographykey
order by
  customer_key asc;

-- Cleansed dim_products Table --
create table `portfolio-e`.dim_product_exploration as
SELECT
  p.ProductKey,
  p.ProductAlternateKey AS product_item_Code,
  p.EnglishProductName AS product_name,
  ps.EnglishProductSubcategoryName AS sub_category,
  -- Joined in from Sub Category Table
  pc.EnglishProductCategoryName AS product_category,
  -- Joined in from Category Table
  p.Color AS product_color,
  p.Size AS product_size,
  p.ProductLine AS product_line,
  p.ModelName AS product_model_name,
  p.EnglishDescription AS product_description,
  ifNULL (p.Status, 'Outdated') AS product_status
FROM
  `portfolio-e`.dim_products AS p
  LEFT JOIN `portfolio-e`.dim_product_subcategory AS ps ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey
  LEFT JOIN `portfolio-e`.dim_product_category AS pc ON ps.ProductCategoryKey = pc.ProductCategoryKey
order by
  p.ProductKey asc;

-- Cleansed FACT_InternetSales Table --
SELECT
  ProductKey as product_key,
  OrderDateKey as order_date_key,
  DueDateKey as due_date_key,
  ShipDateKey as ship_date_key,
  CustomerKey as customer_key,
  SalesOrderNumber as sales_order_number,
  SalesAmount as sales_amount
FROM
  `portfolio-e`.fact_internetsales
WHERE
  LEFT (OrderDateKey, 4) >= 2019 - -- Ensures always only bring two years of date from extraction.
ORDER BY
  OrderDateKey asc;