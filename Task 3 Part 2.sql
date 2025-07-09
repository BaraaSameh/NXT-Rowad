use StoreDB
go
--1
select [product_name] ,
[list_price] as price
from [production].[products]
where [list_price] >1000
order by list_price 

--2
select [first_name] +' '+ [last_name] as name, state 
from[sales].[customers]
where state in('CA','NY');

--3 

select [order_date] from [sales].[orders]
where YEAR([order_date])=2023;


select * from [sales].[orders]
where YEAR([order_date])=2023;
--4
select *
from [sales].[customers]
where [email] like '%@gmail.com';

--5

select * 
from [sales].[staffs] 
where [active] is null; -- no data is inactive 

--6 

select top 5 [product_name],[list_price]
from [production].[products]
order by [list_price] desc

--7

select top 10 [order_id],[order_status],[order_date]
from [sales].[orders]
order by [order_date] desc

--8 

select top 3 [first_name]+' '+[last_name]as fullname 
from [sales].[customers]
order by[last_name] desc

--9 
select [first_name]+' '+[last_name] as fullname ,[city] ,[phone]
from [sales].[customers]
where phone is null
--
--10 

select [first_name], [phone],[email]
from [sales].[staffs]
where [manager_id]is not null;

--11

select [category_id], COUNT(*) as prcount
from[production].[products]
group by [category_id]

--12

select [state],COUNT(*) as customerno
from[sales].[customers]
group by [state];
--12.1

select [state],COUNT(*) as customerno
from[sales].[customers]
group by [state];-- error [customer_id]

--13 

select[brand_id], AVG([list_price]) as avg
from[production].[products]	
group by [brand_id]

--14
select[staff_id],COUNT(*) as ordercount  
from[sales].[orders]
group by [staff_id]

--15 

select [customer_id]
from [sales].[orders]
where[order_id]>2

--15.1
select[customer_id],COUNT(*) as orderco
from [sales].[orders]
group by [customer_id]
having COUNT(*)>2

--16

select [product_name],[list_price]
from [production].[products]
where [list_price] between 500 and 1500

--17

select [first_name],[city]
from[sales].[customers]
where [city] like 'S%';

--18 

select*
from [sales].[orders]
where[order_status]  in (2 , 4);

--19

select[product_name]
from[production].[products]
where [category_id] in (1,2,3);

--20 

select *
from[sales].[staffs]
where[store_id] =1 or[phone] is null
-- Part One Done 








