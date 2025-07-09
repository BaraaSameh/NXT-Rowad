---Task 4 SQL start ---
use StoreDB

--1
select count(*)
from [production].[products]

--2

select AVG([list_price]) as avg
from[production].[products]

select max([list_price]) as max
from[production].[products]

select min([list_price]) as min
from[production].[products]

--3

select count(*)as pd
from[production].[products]
group by[product_id] -- ask 

--4

select s.store_name,COUNT(o.order_id) as total
from[sales].[stores] s
join [sales].[orders] o on s.store_id= o.store_id
group by s.store_name -- after solved 

SELECT s.store_name, COUNT(o.order_id) AS total_orders
FROM[sales].[stores]  s
JOIN [sales].[orders]o ON s.store_id = o.store_id
GROUP BY s.store_name; -- revi

--5
select top 10 UPPER([first_name]) as first_name,LOWER([last_name])as last_name
from [sales].[customers]
-- order bttl3 nfs el esm msh 3arf leeh ......
--order by first_name desc

--6

select top 10 [product_name],
len([product_name]) as lentgh
from [production].[products]

--7

select top 15 [first_name]+' '+[last_name],[phone],
left([phone],3)as phonecode 
from[sales].[customers]

--8

select top 10[order_date],YEAR([order_date]) as year,MONTH([order_date]) as month
from[sales].[orders]
order by [order_date]

--9 

select top 10 p.product_name,pp.category_name
from [production].[products]p
join [production].[categories]pp on p.category_id=pp.category_id
order by p.product_name

--10 
SELECT TOP 10 
  c.first_name+' '+last_name,
  o.order_date
FROM [sales].[customers] c
JOIN [sales].[orders] o ON c.customer_id = o.customer_id;

--11

select p.product_name ,b.brand_name,
isnull(b.brand_name,'not found')
from [production].[products]p
 left join [production].[brands]b on p.brand_id=b.brand_id

 --12 
 select p.product_name,p.list_price
 from [production].[products]p 
 where p.list_price> (select AVG(p.list_price)from[production].[products]p);
 
 --13

 select C.customer_id,c.first_name
 from [sales].[customers] C
 where c.customer_id in(select c.customer_id from[sales].[customers])

 --14

 SELECT 
 first_name ,
  (
    SELECT COUNT(*) 
    FROM [sales].[orders] o
    WHERE o.customer_id = c.customer_id
  ) AS total_orders
FROM [sales].[customers] c;
--15
-- revi
CREATE VIEW easy_product_list AS
SELECT 
  p.product_name,
  c.category_name,
  p.list_price
FROM [production].[products] p
JOIN [production].[categories] c ON p.category_id = c.category_id;

--16
CREATE VIEW customer_info AS
SELECT 
  customer_id,
  first_name + ' ' + last_name AS full_name,
  email,
  city + ', ' + state AS location
FROM [sales].[customers];


SELECT *
FROM customer_info
WHERE location LIKE '%, CA';

--17

SELECT 
  product_name,
p.list_price
from[production].[products]p
WHERE list_price BETWEEN 50 AND 200
ORDER BY list_price ASC;

--18

SELECT 
  state,
  COUNT(*) AS customer_count
FROM [sales].[customers]
GROUP BY state
ORDER BY customer_count DESC;

--19

SELECT 
  c.category_name,
  p.product_name,
  p.list_price
FROM [production].[products] p
JOIN [production].[categories] c ON p.category_id = c.category_id
WHERE p.list_price = (
  SELECT MAX(p.list_price)
  FROM[production].[products]  p2
  WHERE p2.category_id = p.category_id
); ---- error (An aggregate may not appear in the WHERE clause unless it is in a subquery contained in a HAVING clause or a select list, and the column being aggregated is an outer reference.)

SELECT category_id, COUNT(*) AS total_products
FROM [production].[categories]
GROUP BY category_id
HAVING COUNT(*) > 5;

--20

SELECT 
  s.store_name,
  s.city,
  COUNT(o.order_id) AS order_count
FROM [sales].[stores] s
JOIN [sales].[orders] o ON s.store_id = o.store_id
GROUP BY s.store_name, s.city;


--- Task 4 SQL Done  ---















