use StoreDB

--1

select p.product_name,p.list_price,
case p.list_price
when < 300 then'economy'
when between 300 and 999 then 'standard'
when between 1000 and 2499 then 'premiuem'
when >= 2500 then 'Luxury'
end as price
from[production].[products]p
-- error 

SELECT 
  p.product_name,
  p.list_price,
  CASE 
    WHEN p.list_price < 300 THEN 'Economy'
    WHEN p.list_price BETWEEN 300 AND 999 THEN 'Standard'
    WHEN p.list_price BETWEEN 1000 AND 2499 THEN 'Premium'
    WHEN p.list_price >= 2500 THEN 'Luxury'
  END AS price_category
FROM production.products p;

--2

select o.order_status,o.order_id,o.order_date,
case o.order_status
WHEN 1 THEN 'Order Received'
WHEN 2 THEN 'In Preparation'
WHEN 3 THEN 'Order Cancelled'
WHEN 4 THEN 'Order Delivered'
end as status_description,
case 
WHEN o.order_status = 1 AND DATEDIFF(DAY, o.order_date, GETDATE()) > 5 THEN 'URGENT'
WHEN o.order_status = 2 AND DATEDIFF(DAY, o.order_date, GETDATE()) > 3 THEN 'HIGH'
ELSE 'NORMAL' 
end as per_level

from [sales].[orders]o

--3   --- every order has a unique id so we will count them ---
SELECT 
  s.staff_id,
  s.first_name + ' ' + s.last_name AS staff_name,
  COUNT(o.order_id) AS order_count,
  CASE 
    WHEN COUNT(o.order_id) = 0 THEN 'New Staff'
    WHEN COUNT(o.order_id) BETWEEN 1 AND 10 THEN 'Junior Staff'
    WHEN COUNT(o.order_id) BETWEEN 11 AND 25 THEN 'Senior Staff'
    ELSE 'Expert Staff'
  END AS staff_category
FROM sales.staffs s
LEFT JOIN sales.orders o ON s.staff_id = o.staff_id
GROUP BY s.staff_id, s.first_name, s.last_name;

---4 
select s.first_name+' '+s.last_name ,s.email ,
COALESCE(phone, email, 'No Contact Info') AS best_contact_method

from [sales].[staffs]s

select s.first_name+' '+s.last_name ,s.email ,
isnull(phone, 'No Contact Info') AS best_contact_method

from [sales].[staffs]s



--5

SELECT 
  p.product_id,
  p.product_name,
  i.quantity,
  ISNULL(p.list_price / NULLIF(i.quantity, 0), 0) AS price_per_unit,
  CASE 
    WHEN i.quantity = 0 THEN 'Out of Stock'
    WHEN i.quantity IS NULL THEN 'Not Available'
    ELSE 'In Stock'
  END AS stock_status
FROM production.products p
JOIN production.stocks i 
  ON p.product_id = i.product_id
WHERE i.store_id = 1;


--6
SELECT 
  c.customer_id, c.first_name + ' ' + c.last_name AS customer_name,
  COALESCE(c.street, '') AS street_address,
  COALESCE(c.city, '') AS city,
  COALESCE(c.state, '') AS state,
  COALESCE(c.zip_code, 'No ZIP Provided') AS zip_code,
  -- Combine everything into a single formatted address
  COALESCE(c.street, '') + ', ' +
  COALESCE(c.city, '') + ', ' +
  COALESCE(c.state, '') + ' ' +
  COALESCE(c.zip_code, 'No ZIP Provided') AS formatted_address
FROM sales.customers c;


--7 
WITH customer_spending AS (
  SELECT  c.customer_id, c.first_name,  c.last_name,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spent
  FROM sales.customers c
  JOIN sales.orders o ON c.customer_id = o.customer_id
  JOIN sales.order_items oi ON o.order_id = oi.order_id
  GROUP BY c.customer_id, c.first_name, c.last_name
)

SELECT customer_id,first_name + ' ' + last_name AS customer_name,
  total_spent
FROM customer_spending
WHERE total_spent > 1500
ORDER BY total_spent DESC; ---- ----------- --------------- -------------------------- -----err

--8

WITH category_revenue AS (
  SELECT 
    c.category_id,
    c.category_name,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
  FROM production.categories c
  JOIN production.products p ON c.category_id = p.category_id
  JOIN sales.order_items oi ON p.product_id = oi.product_id
  GROUP BY c.category_id, c.category_name
),
category_avg_order AS (
  SELECT 
    c.category_id,
    AVG(oi.quantity * oi.list_price * (1 - oi.discount)) AS avg_order_value
  FROM production.categories c
  JOIN production.products p ON c.category_id = p.category_id
  JOIN sales.order_items oi ON p.product_id = oi.product_id
  GROUP BY c.category_id
)

SELECT 
  r.category_id,
  r.category_name,
  r.total_revenue,          ------- -
  a.avg_order_value,
  CASE 
    WHEN r.total_revenue > 50000 THEN 'Excellent'
    WHEN r.total_revenue > 20000 THEN 'Good'
    ELSE 'Needs Improvement'
  END AS performance_rating
FROM category_revenue r
JOIN category_avg_order a ON r.category_id = a.category_id
ORDER BY r.total_revenue DESC;

--9

WITH monthly_sales AS (
  SELECT 
    FORMAT(o.order_date, 'yyyy-MM') AS sales_month,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
  FROM sales.orders o
  JOIN sales.order_items oi ON o.order_id = oi.order_id
  GROUP BY FORMAT(o.order_date, 'yyyy-MM')
),
monthly_growth AS (
  SELECT 
    ms.sales_month,
    ms.total_revenue,
    LAG(ms.total_revenue) OVER (ORDER BY ms.sales_month) AS previous_month_revenue,
    CASE 
      WHEN LAG(ms.total_revenue) OVER (ORDER BY ms.sales_month) IS NULL THEN NULL
      ELSE ROUND(
        ((ms.total_revenue - LAG(ms.total_revenue) OVER (ORDER BY ms.sales_month)) * 100.0) 
        / LAG(ms.total_revenue) OVER (ORDER BY ms.sales_month), 2)
    END AS growth_percentage
  FROM monthly_sales ms
)

SELECT 
  sales_month,
  total_revenue,
  previous_month_revenue,
  growth_percentage
FROM monthly_growth
ORDER BY sales_month;

--10 

select top 3  p.list_price,c.category_name ,p.product_name,
row_number() over(order by[list_price])as row , 
rank () over (order by[list_price])as rank ,
dense_rank() over (order by[list_price]) as dense

from [production].[products]p
join [production].[categories]c on p.category_id=c.category_id

--11

SELECT 
  c.customer_id,
  c.first_name + ' ' + c.last_name AS customer_name,
  SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_spent,

  -- Rank customers by total_spent (handles ties with gaps)
  RANK() OVER (ORDER BY SUM(oi.quantity * oi.list_price * (1 - oi.discount)) DESC) AS spending_rank,

  -- Divide into 5 spending groups
  NTILE(5) OVER (ORDER BY SUM(oi.quantity * oi.list_price * (1 - oi.discount)) DESC) AS spending_group,

  -- Assign tier labels based on group number
  CASE 
    WHEN NTILE(5) OVER (ORDER BY SUM(oi.quantity * oi.list_price * (1 - oi.discount)) DESC) = 1 THEN 'VIP'
    WHEN NTILE(5) OVER (ORDER BY SUM(oi.quantity * oi.list_price * (1 - oi.discount)) DESC) = 2 THEN 'Gold'
    WHEN NTILE(5) OVER (ORDER BY SUM(oi.quantity * oi.list_price * (1 - oi.discount)) DESC) = 3 THEN 'Silver'
    WHEN NTILE(5) OVER (ORDER BY SUM(oi.quantity * oi.list_price * (1 - oi.discount)) DESC) = 4 THEN 'Bronze'
    ELSE 'Standard'
  END AS spending_tier

FROM sales.customers c
JOIN sales.orders o ON c.customer_id = o.customer_id
JOIN sales.order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

--12
    SELECT 
  s.store_id,
  s.store_name,
  SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue,
  COUNT(DISTINCT o.order_id) AS total_orders,
  RANK() OVER (ORDER BY SUM(oi.quantity * oi.list_price * (1 - oi.discount)) DESC) AS revenue_rank,
  RANK() OVER (ORDER BY COUNT(DISTINCT o.order_id) DESC) AS order_volume_rank,
  PERCENT_RANK() OVER (ORDER BY SUM(oi.quantity * oi.list_price * (1 - oi.discount))) AS revenue_percentile

FROM sales.stores s
JOIN sales.orders o ON s.store_id = o.store_id
JOIN sales.order_items oi ON o.order_id = oi.order_id
GROUP BY s.store_id, s.store_name
ORDER BY total_revenue DESC;

--13 

SELECT *
FROM (
  SELECT 
    c.category_name,
    b.brand_name,
    p.product_id
  FROM production.products p
  JOIN production.categories c ON p.category_id = c.category_id
  JOIN production.brands b ON p.brand_id = b.brand_id
  WHERE b.brand_name IN ('Electra', 'Haro', 'Trek', 'Surly')
) AS source
PIVOT (
  COUNT(product_id)
  FOR brand_name IN ([Electra], [Haro], [Trek], [Surly])
) AS product_pivot;--- no ans 

--14

SELECT 
  store_name,
  ISNULL([Jan], 0) AS Jan,
  ISNULL([Feb], 0) AS Feb,
  ISNULL([Mar], 0) AS Mar,
  ISNULL([Apr], 0) AS Apr,
  ISNULL([May], 0) AS May,
  ISNULL([Jun], 0) AS Jun,
  ISNULL([Jul], 0) AS Jul,
  ISNULL([Aug], 0) AS Aug,
  ISNULL([Sep], 0) AS Sep,
  ISNULL([Oct], 0) AS Oct,
  ISNULL([Nov], 0) AS Nov,
  ISNULL([Dec], 0) AS Dec,

  -- Add total column across all months
  ISNULL([Jan], 0) + ISNULL([Feb], 0) + ISNULL([Mar], 0) +
  ISNULL([Apr], 0) + ISNULL([May], 0) + ISNULL([Jun], 0) +
  ISNULL([Jul], 0) + ISNULL([Aug], 0) + ISNULL([Sep], 0) +
  ISNULL([Oct], 0) + ISNULL([Nov], 0) + ISNULL([Dec], 0) AS Total_Revenue

FROM (
  SELECT 
    s.store_name,
    DATENAME(MONTH, o.order_date) AS sales_month,
    oi.quantity * oi.list_price * (1 - oi.discount) AS revenue
  FROM sales.stores s
  JOIN sales.orders o ON s.store_id = o.store_id
  JOIN sales.order_items oi ON o.order_id = oi.order_id
) AS source
PIVOT (
  SUM(revenue)
  FOR sales_month IN ([Jan], [Feb], [Mar], [Apr], [May], [Jun], [Jul], [Aug], [Sep], [Oct], [Nov], [Dec])
) AS pivot_table;

--15

SELECT 
  store_name,
  ISNULL([Pending], 0) AS Pending,
  ISNULL([Processing], 0) AS Processing,
  ISNULL([Completed], 0) AS Completed,
  ISNULL([Rejected], 0) AS Rejected
FROM (
  SELECT 
    s.store_name,
    CASE o.order_status
      WHEN 1 THEN 'Pending'
      WHEN 2 THEN 'Processing'
      WHEN 3 THEN 'Completed'
      WHEN 4 THEN 'Rejected'
    END AS status_label
  FROM sales.orders o
  JOIN sales.stores s ON o.store_id = s.store_id
) AS status_data
PIVOT (
  COUNT(o.[store_id])
  FOR status_label IN ([Pending], [Processing], [Completed], [Rejected])
) AS pivot_table;
--error

--16


------------------------

--17 




-- Query 1: In-stock products (quantity > 0)
SELECT 
  p.product_id,
  p.product_name,
  'In Stock' AS availability_status
FROM production.products p
JOIN production.stocks s ON p.product_id = s.product_id
WHERE s.quantity > 0

UNION

-- Query 2: Out-of-stock products (quantity = 0 or NULL)
SELECT 
  p.product_id,
  p.product_name,
  'Out of Stock' AS availability_status
FROM production.products p
JOIN production.stocks s ON p.product_id = s.product_id
WHERE s.quantity = 0 OR s.quantity IS NULL

UNION

-- Query 3: Discontinued products (not in stocks table)
SELECT 
  p.product_id,
  p.product_name,
  'Discontinued' AS availability_status
FROM production.products p
WHERE p.product_id NOT IN (
  SELECT product_id FROM production.stocks
);


--18


-- Step 1: Get customer IDs in 2017
SELECT DISTINCT o.customer_id
FROM sales.orders o
WHERE YEAR(o.order_date) = 2017

INTERSECT

-- Step 2: Get customer IDs  in 2018
SELECT DISTINCT o.customer_id
FROM sales.orders o
WHERE YEAR(o.order_date) = 2018 -- no ans 

--19 

-- Products available in all 3 stores
SELECT product_id, 'Available in All Stores' AS distribution_status
FROM production.stocks
WHERE store_id IN (1, 2, 3)
GROUP BY product_id
HAVING COUNT(DISTINCT store_id) = 3

UNION

-- Products in store 1 but not in store 2
SELECT product_id, 'Only in Store 1' AS distribution_status
FROM production.stocks
WHERE store_id = 1
EXCEPT
SELECT product_id, 'Only in Store 1' AS distribution_status
FROM production.stocks
WHERE store_id = 2;


--20 

-- Lost customers: Bought in 2016 but not in 2017
SELECT 
  c.customer_id,
  c.first_name + ' ' + c.last_name AS customer_name,
  'Lost' AS retention_status
FROM sales.customers c
WHERE c.customer_id IN (
  SELECT customer_id FROM sales.orders WHERE YEAR(order_date) = 2016
  EXCEPT
  SELECT customer_id FROM sales.orders WHERE YEAR(order_date) = 2017
)

UNION ALL

-- New customers: Bought in 2017 but not in 2016
SELECT 
  c.customer_id,
  c.first_name + ' ' + c.last_name AS customer_name,
  'New' AS retention_status
FROM sales.customers c
WHERE c.customer_id IN (
  SELECT customer_id FROM sales.orders WHERE YEAR(order_date) = 2017
  EXCEPT
  SELECT customer_id FROM sales.orders WHERE YEAR(order_date) = 2016
)

UNION ALL

-- Retained customers: Bought in both 2016 and 2017
SELECT 
  c.customer_id,
  c.first_name + ' ' + c.last_name AS customer_name,
  'Retained' AS retention_status
FROM sales.customers c
WHERE c.customer_id IN (
  SELECT customer_id FROM sales.orders WHERE YEAR(order_date) = 2016
  INTERSECT
  SELECT customer_id FROM sales.orders WHERE YEAR(order_date) = 2017
); ------ no ans 







