--1

declare @cid int=1;
declare @totalamount decimal(10,2);
declare @cstatues nvarchar(max);

select @totalamount =SUM([order_id])
from [sales].[orders]
where [customer_id]=@cid;

if @totalamount>1000
 set @cstatues='vip'
 else
 set @cstatues='nonvip'
 PRINT 'Customer ID: ' + CAST(@cid AS VARCHAR);
PRINT 'Total Spent: $' + CAST(@totalamount AS VARCHAR);
PRINT 'Status: ' + @cstatues;

--2 
 declare @prodects int ;
 declare @cost int;

 select  @prodects =COUNT (p.list_price)
 from[production].[products]p
 where p.list_price= @cost

 if @cost =1500
 print'equal'
 else if @cost>1500
 print 'more'
 else
 print'low'


-- DECLARE @ThresholdPrice DECIMAL(10,2) = 1500.00;
--DECLARE @ProductCount INT;

---- Count products above the threshold
--SELECT @ProductCount = COUNT(*)
--FROM [production].[products]
--WHERE [list_price] > @ThresholdPrice;

---- Display formatted message
--PRINT 'Threshold Price: $' + CAST(@ThresholdPrice AS VARCHAR);
--PRINT 'Number of Products Above Threshold: ' + CAST(@ProductCount AS VARCHAR);

--3

declare @Sid int=2;
--declare @salesy int=2017;
declare @total decimal(10,2);
select @total=sum([order_id])
from[sales].[orders]
where @Sid=[staff_id]-- and @salesy= [order_date];

PRINT 'Staff ID: ' + CAST(@Sid AS VARCHAR);
--PRINT 'Sales Year: ' + CAST(@salesy AS VARCHAR);
PRINT 'Total Sales: $' + CAST(@total AS VARCHAR);


--4 
SELECT 
    @@SERVERNAME AS [Server Name],
    @@VERSION AS [SQL Server Version],
    @@ROWCOUNT AS [Rows Affected by Last Statement];

    --5 

   declare @pid int =1;
   declare @sid int=1;
   declare @qu int ;

   select @qu =[quantity]
   from[production].[stocks]
   where @pid=[product_id] and @Sid=[store_id]

   IF @qu > 20
    PRINT 'Well stocked';
ELSE IF @qu BETWEEN 10 AND 20
    PRINT 'Moderate stock';
ELSE IF @qu < 10
    PRINT 'Low stock - reorder needed';

    --6
    DECLARE @BatchSize INT = 3;
DECLARE @UpdatedCount INT = 0;

WHILE EXISTS (
    SELECT 1 FROM [production].[stocks] WHERE[quantity]  < 5
)
BEGIN
    -- Update top 3 low-stock products
    UPDATE TOP (@BatchSize) [production].[stocks]
    SET [quantity] = [quantity] + 10
    WHERE [quantity] < 5;

    -- Track progress
    SET @UpdatedCount += @BatchSize;

    PRINT 'Updated ' + CAST(@BatchSize AS VARCHAR) + ' low-stock products. Total updated so far: ' + CAST(@UpdatedCount AS VARCHAR);
END--revi 

--7 

select [product_id],[product_name],[list_price],
case    
WHEN [list_price] < 300 THEN 'Budget'
WHEN [list_price] BETWEEN 300 AND 800 THEN 'Mid-Range'
WHEN [list_price] BETWEEN 801 AND 2000 THEN 'Premium'
WHEN [list_price] > 2000 THEN 'Luxury'
ELSE 'Uncategorized'
end as PriceCategory
from [production].[products]
--8

DECLARE @CustomerID INT = 5;
DECLARE @OrderCount INT;

-- Check if customer exists and get order count
SELECT @OrderCount = COUNT(*)
FROM [sales].[orders]
WHERE [customer_id] = @CustomerID;

-- Display result
IF @OrderCount > 0
BEGIN
    PRINT 'Customer ID ' + CAST(@CustomerID AS VARCHAR) + ' has placed ' + CAST(@OrderCount AS VARCHAR) + ' orders.';
END
ELSE
BEGIN
    PRINT 'Customer ID ' + CAST(@CustomerID AS VARCHAR) + ' does not exist or has no orders.';
END--revi 

--9

CREATE FUNCTION CalculateShipping (@OrderTotal DECIMAL(10,2))
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @ShippingCost DECIMAL(5,2);

    SET @ShippingCost = 
        CASE 
            WHEN @OrderTotal > 100 THEN 0.00
            WHEN @OrderTotal BETWEEN 50 AND 99.99 THEN 5.99
            ELSE 12.99
        END;

    RETURN @ShippingCost;
END;--revi

--10

CREATE FUNCTION GetProductsByPriceRange
(
    @MinPrice DECIMAL(10,2),
    @MaxPrice DECIMAL(10,2)
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        p.ProductID,
        p.ProductName,
        p.ListPrice,
        b.BrandName,
        c.CategoryName
    FROM Products p
    INNER JOIN Brands b ON p.BrandID = b.BrandID
    INNER JOIN Categories c ON p.CategoryID = c.CategoryID
    WHERE p.ListPrice BETWEEN @MinPrice AND @MaxPrice
);
SELECT * FROM dbo.GetProductsByPriceRange(500, 1500);

--11

CREATE FUNCTION GetCustomerYearlySummary (@CustomerID INT)
RETURNS @YearlySummary TABLE
(
    SalesYear INT,
    TotalOrders INT,
    TotalSpent DECIMAL(10,2),
    AverageOrderValue DECIMAL(10,2)
)
AS
BEGIN
    INSERT INTO @YearlySummary
    SELECT 
        YEAR([order_date]) AS SalesYear,
        COUNT(*) AS TotalOrders,
        SUM([order_id]) AS TotalSpent,
        AVG([order_id]) AS AverageOrderValue
    FROM Orders
    WHERE[customer_id]  = @CustomerID
    GROUP BY YEAR([order_date]);

    RETURN;
END;

--12

create function CalculateBulkDiscount  (@qu int)
returns decimal (5,2)
as 
begin 
 DECLARE @Discount DECIMAL(5,2);

    SET @Discount = 
        CASE 
            WHEN @qu BETWEEN 1 AND 2 THEN 0.00
            WHEN @qu BETWEEN 3 AND 5 THEN 5.00
            WHEN @qu BETWEEN 6 AND 9 THEN 10.00
            WHEN @qu >= 10 THEN 15.00
            ELSE 0.00
        END;

    RETURN @Discount;
END;
   --13

   CREATE PROCEDURE sp_GetCustomerOrderHistory
    @CustomerID INT,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        o.OrderID,
        o.OrderDate,
        o.TotalAmount,
        c.CustomerName
    FROM Orders o
    INNER JOIN Customers c ON o.CustomerID = c.CustomerID
    WHERE o.CustomerID = @CustomerID
      AND (@StartDate IS NULL OR o.OrderDate >= @StartDate)
      AND (@EndDate IS NULL OR o.OrderDate <= @EndDate)
    ORDER BY o.OrderDate;
END;


--14 

--15

--16
--17
--CREATE PROCEDURE sp_CalculateQuarterlyBonuses
--    @Quarter INT,
--    @Year INT
--AS
--BEGIN
--    SET NOCOUNT ON;

--    -- Define date range for the selected quarter
--    DECLARE @StartDate DATE, @EndDate DATE;

--    IF @Quarter = 1
--        SET @StartDate = DATEFROMPARTS(@Year, 1, 1), @EndDate = DATEFROMPARTS(@Year, 3, 31);
--    ELSE IF @Quarter = 2
--        SET @StartDate = DATEFROMPARTS(@Year, 4, 1), @EndDate = DATEFROMPARTS(@Year, 6, 30);
--    ELSE IF @Quarter = 3
--        SET @StartDate = DATEFROMPARTS(@Year, 7, 1), @EndDate = DATEFROMPARTS(@Year, 9, 30);
--    ELSE IF @Quarter = 4
--        SET @StartDate = DATEFROMPARTS(@Year, 10, 1), @EndDate = DATEFROMPARTS(@Year, 12, 31);
--    ELSE
--    BEGIN
--        PRINT 'Invalid quarter. Please enter a value between 1 and 4.';
--        RETURN;
--    END

--    -- Bonus tiers
--    DECLARE @Tier1Rate DECIMAL(5,2) = 0.05;  -- Sales < 10000
--    DECLARE @Tier2Rate DECIMAL(5,2) = 0.10;  -- Sales 10000–19999
--    DECLARE @Tier3Rate DECIMAL(5,2) = 0.15;  -- Sales ≥ 20000

--    -- Calculate bonuses
--    SELECT 
--        s.StaffID,
--        s.StaffName,
--        SUM(o.TotalAmount) AS TotalSales,
--        CASE 
--            WHEN SUM(o.TotalAmount) < 10000 THEN SUM(o.TotalAmount) * @Tier1Rate
--            WHEN SUM(o.TotalAmount) BETWEEN 10000 AND 19999 THEN SUM(o.TotalAmount) * @Tier2Rate
--            WHEN SUM(o.TotalAmount) >= 20000 THEN SUM(o.TotalAmount) * @Tier3Rate
--            ELSE 0
--        END AS BonusAmount
--    FROM Orders o
--    INNER JOIN Staff s ON o.StaffID = s.StaffID
--    WHERE o.OrderDate BETWEEN @StartDate AND @EndDate
--    GROUP BY s.StaffID, s.StaffName
--    ORDER BY BonusAmount DESC;
--END;

--18
--DECLARE @ProductID INT, @CategoryID INT, @CurrentQty INT, @ReorderQty INT;

--DECLARE product_cursor CURSOR FOR
--SELECT [product_id], [category_id], [quantity]
--FROM [production].[stocks]s
--INNER JOIN [production].[products]p ON product_id = product_id;

--OPEN product_cursor;
--FETCH NEXT FROM product_cursor INTO @ProductID, @CategoryID, @CurrentQty;

--WHILE @@FETCH_STATUS = 0
--BEGIN
--    -- Nested IF logic based on category and stock level
--    IF @CategoryID = 1 -- Electronics
--    BEGIN
--        IF @CurrentQty < 5
--            SET @ReorderQty = 20;
--        ELSE IF @CurrentQty BETWEEN 5 AND 10
--            SET @ReorderQty = 10;
--        ELSE
--            SET @ReorderQty = 0;
--    END
--    ELSE IF @CategoryID = 2 -- Clothing
--    BEGIN
--        IF @CurrentQty < 10
--            SET @ReorderQty = 30;
--        ELSE IF @CurrentQty BETWEEN 10 AND 20
--            SET @ReorderQty = 15;
--        ELSE
--            SET @ReorderQty = 0;
--    END
--    ELSE -- Other categories
--    BEGIN
--        IF @CurrentQty < 8
--            SET @ReorderQty = 25;
--        ELSE
--            SET @ReorderQty = 0;
--    END

--    -- Apply restock if needed
--    IF @ReorderQty > 0
--    BEGIN
--        UPDATE Stocks
--        SET Quantity = Quantity + @ReorderQty
--        WHERE ProductID = @ProductID;

--        PRINT 'Product ID ' + CAST(@ProductID AS VARCHAR) + 
--              ' restocked with ' + CAST(@ReorderQty AS VARCHAR) + 
--              ' units. New quantity: ' + CAST(@CurrentQty + @ReorderQty AS VARCHAR);
--    END

--    FETCH NEXT FROM product_cursor INTO @ProductID, @CategoryID, @CurrentQty;
--END

--CLOSE product_cursor;
--DEALLOCATE product_cursor;


--19

SELECT 
    c.customer_id,
   c.first_name,
    ISNULL(SUM(o.order_id), 0) AS TotalSpent,
    CASE 
        WHEN SUM(o.order_id) IS NULL THEN 'No Orders'
        WHEN SUM(o.order_id) < 1000 THEN 'Bronze'
        WHEN SUM(o.order_id) BETWEEN 1000 AND 4999 THEN 'Silver'
        WHEN SUM(o.order_id) BETWEEN 5000 AND 9999 THEN 'Gold'
        WHEN SUM(o.order_id) >= 10000 THEN 'Platinum'
        ELSE 'Uncategorized'
    END AS LoyaltyTier
FROM[sales].[customers] c
LEFT JOIN [sales].[orders] o ON c.[customer_id] = o.[customer_id]
GROUP BY c.[customer_id], c.[first_name]
ORDER BY TotalSpent DESC;


--20 21  22 



