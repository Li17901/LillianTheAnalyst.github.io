-- Clean,explore and extract dim_calendar Table --
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

-- Clean,explore and extract dim_customers Table --
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
  CasE
    c.gender
    WHEN 'M' THEN 'Male'
    WHEN 'F' THEN 'Female'
  END as gender,
  c.date_first_purchase,
  g.city as customer_city
from
  `portfolio-e`.dim_customers c
  left join `portfolio-e`.`dim-geography` g on c.geographykey = g.geographykey
order by
  customer_key asc;

-- Clean,explore and extract dim_products Table --
create table `portfolio-e`.dim_product_exploration as
SELECT
  p.ProductKey,
  p.ProductAlternateKey as product_item_Code,
  p.EnglishProductName as product_name,
  ps.EnglishProductSubcategoryName as sub_category,
  -- Joined in from Sub Category Table
  pc.EnglishProductCategoryName as product_category,
  -- Joined in from Category Table
  p.Color as product_color,
  p.Size as product_size,
  p.ProductLine as product_line,
  p.ModelName as product_model_name,
  p.EnglishDescription as product_description,
  ifNULL (p.Status, 'Outdated') as product_status
FROM
  `portfolio-e`.dim_products as p
  LEFT JOIN `portfolio-e`.dim_product_subcategory as ps ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey
  LEFT JOIN `portfolio-e`.dim_product_category as pc ON ps.ProductCategoryKey = pc.ProductCategoryKey
order by
  p.ProductKey asc;

-- Clean,explore and extract FACT_InternetSales Table --
create table `portfolio-e`.dim_fact_InternetSales_exploration as
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
  LEFT (OrderDateKey, 4) >= 2019
ORDER BY
  OrderDateKey asc;