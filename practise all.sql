-----------------------
SELECT p.BusinessEntityID AS EmployeeID, p.FirstName, p.LastName, e.HireDate
FROM HumanResources.Employee AS e
JOIN Person.Person AS p ON e.BusinessEntityID = p.BusinessEntityID
WHERE e.HireDate > '2012-01-01'
ORDER BY e.HireDate DESC;
---------------------
SELECT ProductID, Name, ListPrice, ProductNumber
FROM Production.Product
WHERE ListPrice BETWEEN 100 AND 500
ORDER BY ListPrice ASC;
-------------------
SELECT c.CustomerID, p.FirstName, p.LastName, a.City
FROM Sales.Customer AS c
JOIN Person.Person AS p ON c.PersonID = p.BusinessEntityID
JOIN Person.BusinessEntityAddress AS bea ON p.BusinessEntityID = bea.BusinessEntityID
JOIN Person.Address AS a ON bea.AddressID = a.AddressID
WHERE a.City IN ('Seattle', 'Portland');
--------------------
SELECT TOP 15 p.Name, p.ListPrice, p.ProductNumber, pc.Name AS CategoryName
FROM Production.Product AS p
JOIN Production.ProductSubcategory AS ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory AS pc ON ps.ProductCategoryID = pc.ProductCategoryID
WHERE p.SellEndDate IS NULL
ORDER BY p.ListPrice DESC;
-------------------
SELECT ProductID, Name, Color, ListPrice
FROM Production.Product
WHERE Name LIKE '%Mountain%' AND Color = 'Black';
--------------------------
SELECT p.FirstName + ' ' + ISNULL(p.MiddleName + ' ', '') + p.LastName AS FullName, e.BirthDate, DATEDIFF(year, e.BirthDate, GETDATE()) AS AgeInYears
FROM HumanResources.Employee AS e
JOIN Person.Person AS p ON e.BusinessEntityID = p.BusinessEntityID
WHERE e.BirthDate BETWEEN '1970-01-01' AND '1985-12-31';
----------------------
SELECT SalesOrderID, OrderDate, CustomerID, TotalDue
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2013 AND DATEPART(qq, OrderDate) = 4;
----------------
SELECT ProductID, Name, Weight, Size, ProductNumber
FROM Production.Product
WHERE Weight IS NULL AND Size IS NOT NULL;
---------------
SELECT pc.Name AS Category, COUNT(p.ProductID) AS ProductCount
FROM Production.Product AS p
JOIN Production.ProductSubcategory AS ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory AS pc ON ps.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.Name
ORDER BY ProductCount DESC;
-----------------
SELECT ps.Name AS Subcategory, AVG(p.ListPrice) AS AveragePrice
FROM Production.Product AS p
JOIN Production.ProductSubcategory AS ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
GROUP BY ps.Name
HAVING COUNT(p.ProductID) > 5;
------------------
SELECT TOP 10 p.FirstName + ' ' + p.LastName AS CustomerName, COUNT(soh.SalesOrderID) AS TotalOrders
FROM Sales.Customer AS c
JOIN Person.Person AS p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
GROUP BY p.FirstName, p.LastName
ORDER BY TotalOrders DESC;
-------------------
SELECT DATENAME(month, OrderDate) AS MonthName, SUM(TotalDue) AS TotalAmount
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2013
GROUP BY DATENAME(month, OrderDate), MONTH(OrderDate)
ORDER BY MONTH(OrderDate);
------------------
SELECT ProductID, Name, SellStartDate, YEAR(SellStartDate) AS SellStartYear
FROM Production.Product
WHERE YEAR(SellStartDate) = (SELECT YEAR(SellStartDate) FROM Production.Product WHERE Name = 'Mountain-100 Black, 42');
----------------
WITH DuplicateHireDates AS (
    SELECT HireDate, COUNT(*) AS EmployeeCount
    FROM HumanResources.Employee
    GROUP BY HireDate
    HAVING COUNT(*) > 1
)
SELECT p.FirstName + ' ' + p.LastName AS EmployeeName, dhd.HireDate, dhd.EmployeeCount
FROM HumanResources.Employee AS e
JOIN Person.Person AS p ON e.BusinessEntityID = p.BusinessEntityID
JOIN DuplicateHireDates AS dhd ON e.HireDate = dhd.HireDate
ORDER BY dhd.HireDate, EmployeeName;
-----------------
CREATE TABLE Sales.ProductReviews (
    ReviewID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL FOREIGN KEY REFERENCES Production.Product(ProductID),
    CustomerID INT NOT NULL FOREIGN KEY REFERENCES Sales.Customer(CustomerID),
    Rating INT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    ReviewDate DATETIME DEFAULT GETDATE(),
    ReviewText NVARCHAR(MAX),
    VerifiedPurchaseFlag BIT DEFAULT 0,
    HelpfulVotes INT DEFAULT 0,
    CONSTRAINT UQ_ProductReviews_ProductID_CustomerID UNIQUE (ProductID, CustomerID)
);
--------------
ALTER TABLE Production.Product
ADD LastModifiedDate DATETIME DEFAULT GETDATE();
------------
CREATE NONCLUSTERED INDEX IX_Person_LastName_FirstName_MiddleName
ON Person.Person (LastName, FirstName, MiddleName);
----------
ALTER TABLE Production.Product
ADD CONSTRAINT CK_Product_ListPrice_vs_StandardCost CHECK (ListPrice > StandardCost);
------------
INSERT INTO Sales.ProductReviews (ProductID, CustomerID, Rating, ReviewText, VerifiedPurchaseFlag, HelpfulVotes)
VALUES (775, 29825, 5, 'Excellent mountain bike, very sturdy and smooth ride!', 1, 10);

INSERT INTO Sales.ProductReviews (ProductID, CustomerID, Rating, ReviewText, VerifiedPurchaseFlag, HelpfulVotes)
VALUES (776, 11000, 4, 'Good bike for the price, but assembly was a bit tricky.', 0, 5);

INSERT INTO Sales.ProductReviews (ProductID, CustomerID, Rating, ReviewText, VerifiedPurchaseFlag, HelpfulVotes)
VALUES (777, 20000, 3, 'Decent bike, but the color is not as vibrant as I expected.', 1, 2);
-----------
INSERT INTO Production.ProductCategory (Name) VALUES ('Electronics');

DECLARE @NewCategoryID INT;
SET @NewCategoryID = SCOPE_IDENTITY();

INSERT INTO Production.ProductSubcategory (ProductCategoryID, Name) VALUES (@NewCategoryID, 'Smartphones');
--------
SELECT ProductID, Name, ProductNumber, MakeFlag, FinishedGoodsFlag, Color, SafetyStockLevel, ReorderPoint, StandardCost, ListPrice, Size, SizeUnitMeasureCode, Weight, WeightUnitMeasureCode, DaysToManufacture, ProductLine, Class, Style, ProductSubcategoryID, ProductModelID, SellStartDate, SellEndDate, DiscontinuedDate, rowguid, ModifiedDate
INTO Sales.DiscontinuedProducts
FROM Production.Product
WHERE SellEndDate IS NOT NULL;
----------
UPDATE Production.Product
SET ModifiedDate = GETDATE()
WHERE ListPrice > 1000 AND SellEndDate IS NULL;
----
UPDATE P
SET P.ListPrice = P.ListPrice * 1.15, P.ModifiedDate = GETDATE()
FROM Production.Product AS P
JOIN Production.ProductSubcategory AS PS ON P.ProductSubcategoryID = PS.ProductSubcategoryID
JOIN Production.ProductCategory AS PC ON PS.ProductCategoryID = PC.ProductCategoryID
WHERE PC.Name = 'Bikes';
---
--------------------

UPDATE HumanResources.Employee
SET JobTitle = 'Senior ' + JobTitle
WHERE HireDate < '2010-01-01';

--------------------
--
DELETE FROM Sales.ProductReviews
WHERE Rating = 1 AND HelpfulVotes = 0;


----------------------
EXEC sp_MSforeachtable @command1="ALTER TABLE ? NOCHECK CONSTRAINT ALL";

DELETE FROM Production.Product
WHERE NOT EXISTS (SELECT 1 FROM Sales.SalesOrderDetail WHERE Sales.SalesOrderDetail.ProductID = Production.Product.ProductID);

EXEC sp_MSforeachtable @command1="ALTER TABLE ? CHECK CONSTRAINT ALL";
-----------------------


EXEC sp_MSforeachtable @command1="ALTER TABLE ? NOCHECK CONSTRAINT ALL";

DELETE FROM Purchasing.PurchaseOrderHeader
WHERE VendorID IN (SELECT BusinessEntityID FROM Purchasing.Vendor WHERE ActiveFlag = 0);

EXEC sp_MSforeachtable @command1="ALTER TABLE ? CHECK CONSTRAINT ALL";
--------------------

SELECT YEAR(OrderDate) AS SalesYear, SUM(TotalDue) AS TotalSales, AVG(TotalDue) AS AverageOrderValue, COUNT(SalesOrderID) AS OrderCount
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) BETWEEN 2011 AND 2014
GROUP BY YEAR(OrderDate)
ORDER BY SalesYear;


--------------------
SELECT c.CustomerID, COUNT(soh.SalesOrderID) AS TotalOrders, SUM(soh.TotalDue) AS TotalAmount, AVG(soh.TotalDue) AS AverageOrderValue, MIN(soh.OrderDate) AS FirstOrderDate, MAX(soh.OrderDate) AS LastOrderDate
FROM Sales.Customer AS c
JOIN Sales.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID
ORDER BY c.CustomerID;
--------------------

SELECT TOP 20 p.Name AS ProductName, pc.Name AS Category, SUM(sod.OrderQty) AS TotalQuantitySold, SUM(sod.LineTotal) AS TotalRevenue
FROM Production.Product AS p
JOIN Production.ProductSubcategory AS ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory AS pc ON ps.ProductCategoryID = pc.ProductCategoryID
JOIN Sales.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID
GROUP BY p.Name, pc.Name
ORDER BY TotalRevenue DESC;

--------------------

WITH MonthlySales AS (
    SELECT MONTH(OrderDate) AS SalesMonth, DATENAME(month, OrderDate) AS MonthName, SUM(TotalDue) AS MonthlyTotal
    FROM Sales.SalesOrderHeader
    WHERE YEAR(OrderDate) = 2013
    GROUP BY MONTH(OrderDate), DATENAME(month, OrderDate)
),
YearlyTotal AS (
    SELECT SUM(TotalDue) AS TotalSales2013
    FROM Sales.SalesOrderHeader
    WHERE YEAR(OrderDate) = 2013
)
SELECT ms.MonthName, ms.MonthlyTotal, (ms.MonthlyTotal / yt.TotalSales2013) * 100 AS PercentageOfTotal
FROM MonthlySales AS ms, YearlyTotal AS yt
ORDER BY ms.SalesMonth;

--------------------

CREATE VIEW Sales.CustomerSales AS
SELECT c.CustomerID, p.FirstName, p.LastName, SUM(soh.TotalDue) AS TotalSalesAmount, COUNT(soh.SalesOrderID) AS NumberOfOrders
FROM Sales.Customer AS c
JOIN Person.Person AS p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID, p.FirstName, p.LastName;

--------------------

CREATE VIEW Production.ProductDetails AS
SELECT p.ProductID, p.Name AS ProductName, p.ProductNumber, p.Color, p.ListPrice, ps.Name AS SubcategoryName, pc.Name AS CategoryName
FROM Production.Product AS p
JOIN Production.ProductSubcategory AS ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory AS pc ON ps.ProductCategoryID = pc.ProductCategoryID;
--------------------

CREATE VIEW HumanResources.EmployeeContactInfo AS
SELECT e.BusinessEntityID AS EmployeeID, p.FirstName, p.LastName, ea.EmailAddress, pp.PhoneNumber
FROM HumanResources.Employee AS e
JOIN Person.Person AS p ON e.BusinessEntityID = p.BusinessEntityID
LEFT JOIN Person.EmailAddress AS ea ON p.BusinessEntityID = ea.BusinessEntityID
LEFT JOIN Person.PersonPhone AS pp ON p.BusinessEntityID = pp.BusinessEntityID;

--------------------

CREATE FUNCTION Sales.CalculateCustomerTotalSales (@CustomerID INT)
RETURNS MONEY
AS
BEGIN
    DECLARE @TotalSales MONEY;
    SELECT @TotalSales = SUM(TotalDue)
    FROM Sales.SalesOrderHeader
    WHERE CustomerID = @CustomerID;
    RETURN ISNULL(@TotalSales, 0);
END;
--------------------

CREATE FUNCTION HumanResources.CalculateEmployeeAge (@BirthDate DATE)
RETURNS INT
AS
BEGIN
    DECLARE @Age INT;
    SELECT @Age = DATEDIFF(year, @BirthDate, GETDATE());
    RETURN @Age;
END;--------------------
--------------------
CREATE PROCEDURE Sales.GetCustomerOrderHistory @CustomerID INT
AS
BEGIN
    SELECT soh.SalesOrderID, soh.OrderDate, soh.TotalDue
    FROM Sales.SalesOrderHeader AS soh
    WHERE soh.CustomerID = @CustomerID
    ORDER BY soh.OrderDate DESC;
END;
--------------------
EXEC Sales.GetCustomerOrderHistory @CustomerID = 29825;

----------------------------------------

SELECT ProductID, Name, ISNULL(CAST(Weight AS NVARCHAR(50)), N'Not Specified') AS Weight, ISNULL(Size, N'Standard') AS Size, ISNULL(Color, N'Natural') AS Color
FROM Production.Product;
--------------------

SELECT p.FirstName, p.LastName, COALESCE(ea.EmailAddress, ph.PhoneNumber, a.AddressLine1) AS BestContactMethod
FROM Person.Person AS p
LEFT JOIN Person.EmailAddress AS ea ON p.BusinessEntityID = ea.BusinessEntityID
LEFT JOIN Person.PersonPhone AS ph ON p.BusinessEntityID = ph.BusinessEntityID
LEFT JOIN Person.BusinessEntityAddress AS bea ON p.BusinessEntityID = bea.BusinessEntityID
LEFT JOIN Person.Address AS a ON bea.AddressID = a.AddressID;

--------------------v--------------------
-- 
SELECT ProductID, Name, Weight, Size
FROM Production.Product
WHERE Weight IS NULL AND Size IS NOT NULL;--------------------
-- --------------------
SELECT ProductID, Name, Weight, Size
FROM Production.Product
WHERE Weight IS NULL AND Size IS NULL;----------------------------------------
--------------------
WITH EmployeeHierarchy AS (
    SELECT
        e.BusinessEntityID,
        p.FirstName + N' ' + p.LastName AS EmployeeName,
        CAST(NULL AS NVARCHAR(MAX)) AS ManagerName,
        e.OrganizationNode.GetLevel() AS HierarchyLevel,
        e.OrganizationNode AS NodePath
    FROM HumanResources.Employee AS e
    JOIN Person.Person AS p ON e.BusinessEntityID = p.BusinessEntityID
    WHERE e.OrganizationNode.GetLevel() = 0 -- أعلى مستوى في التسلسل الهرمي

    UNION ALL

    SELECT
        e.BusinessEntityID,
        p.FirstName + N' ' + p.LastName AS EmployeeName,
        eh.EmployeeName AS ManagerName,
        e.OrganizationNode.GetLevel() AS HierarchyLevel,
        e.OrganizationNode AS NodePath
    FROM HumanResources.Employee AS e
    JOIN Person.Person AS p ON e.BusinessEntityID = p.BusinessEntityID
    JOIN EmployeeHierarchy AS eh ON e.OrganizationNode.GetAncestor(1) = eh.NodePath
)
SELECT
    EmployeeName,
    ManagerName,
    HierarchyLevel,
    NodePath.ToString() AS Path
FROM EmployeeHierarchy
ORDER BY NodePath;


--------------------------------------------------------------------------------
WITH ProductSales AS (
    SELECT
        p.ProductID,
        p.Name AS ProductName,
        YEAR(soh.OrderDate) AS SalesYear,
        SUM(sod.OrderQty * sod.UnitPrice) AS TotalSales
    FROM Production.Product AS p
    JOIN Sales.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID
    JOIN Sales.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
    WHERE YEAR(soh.OrderDate) IN (2013, 2014)
    GROUP BY p.ProductID, p.Name, YEAR(soh.OrderDate)
)
SELECT
    ps2013.ProductName,
    ps2013.TotalSales AS Sales2013,
    ISNULL(ps2014.TotalSales, 0) AS Sales2014,
    CASE
        WHEN ps2013.TotalSales > 0 THEN ((ISNULL(ps2014.TotalSales, 0) - ps2013.TotalSales) / ps2013.TotalSales) * 100
        ELSE NULL
    END AS GrowthPercentage,
    CASE
        WHEN ps2013.TotalSales > 0 AND ISNULL(ps2014.TotalSales, 0) > ps2013.TotalSales THEN N'Growth'
        WHEN ps2013.TotalSales > 0 AND ISNULL(ps2014.TotalSales, 0) < ps2013.TotalSales THEN N'Decline'
        WHEN ps2013.TotalSales > 0 AND ISNULL(ps2014.TotalSales, 0) = ps2013.TotalSales THEN N'No Change'
        WHEN ps2013.TotalSales = 0 AND ISNULL(ps2014.TotalSales, 0) > 0 THEN N'New Sales'
        ELSE N'No Sales'
    END AS GrowthCategory
FROM ProductSales AS ps2013
LEFT JOIN ProductSales AS ps2014 ON ps2013.ProductID = ps2014.ProductID AND ps2014.SalesYear = 2014
WHERE ps2013.SalesYear = 2013
ORDER BY ps2013.ProductName;----------------------------------------
------------------------------------------------------------
SELECT
    p.Name AS ProductName,
    pc.Name AS Category,
    SUM(sod.OrderQty * sod.UnitPrice) AS SalesAmount,
    RANK() OVER (PARTITION BY pc.Name ORDER BY SUM(sod.OrderQty * sod.UnitPrice) DESC) AS RankBySales,
    DENSE_RANK() OVER (PARTITION BY pc.Name ORDER BY SUM(sod.OrderQty * sod.UnitPrice) DESC) AS DenseRankBySales,
    ROW_NUMBER() OVER (PARTITION BY pc.Name ORDER BY SUM(sod.OrderQty * sod.UnitPrice) DESC) AS RowNumBySales
FROM Production.Product AS p
JOIN Production.ProductSubcategory AS ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory AS pc ON ps.ProductCategoryID = pc.ProductCategoryID
JOIN Sales.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID
GROUP BY p.Name, pc.Name
ORDER BY pc.Name, SalesAmount DESC;

------------------------------------------------------------
SELECT
    DATENAME(month, OrderDate) AS SalesMonth,
    SUM(TotalDue) AS MonthlySales,
    SUM(SUM(TotalDue)) OVER (ORDER BY MONTH(OrderDate)) AS RunningTotal,
    (SUM(SUM(TotalDue)) OVER (ORDER BY MONTH(OrderDate)) / SUM(SUM(TotalDue)) OVER ()) * 100 AS PercentageOfYearToDate
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2013
GROUP BY DATENAME(month, OrderDate), MONTH(OrderDate)
ORDER BY MONTH(OrderDate);
------------------------------------------------------------


SELECT
    st.Name AS TerritoryName,
    DATENAME(month, soh.OrderDate) AS SalesMonth,
    SUM(soh.TotalDue) AS MonthlySales,
    AVG(SUM(soh.TotalDue)) OVER (PARTITION BY st.Name ORDER BY MONTH(soh.OrderDate) ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS ThreeMonthMovingAverage
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.SalesTerritory AS st ON soh.TerritoryID = st.TerritoryID
WHERE YEAR(soh.OrderDate) = 2013
GROUP BY st.Name, DATENAME(month, soh.OrderDate), MONTH(soh.OrderDate)
ORDER BY st.Name, MONTH(soh.OrderDate);
------------------------------------------------------------

WITH MonthlySales AS (
    SELECT
        MONTH(OrderDate) AS SalesMonth,
        DATENAME(month, OrderDate) AS MonthName,
        SUM(TotalDue) AS MonthlyTotal
    FROM Sales.SalesOrderHeader
    WHERE YEAR(OrderDate) = 2013
    GROUP BY MONTH(OrderDate), DATENAME(month, OrderDate)
)
SELECT
    ms.MonthName,
    ms.MonthlyTotal AS CurrentMonthSales,
    LAG(ms.MonthlyTotal, 1, 0) OVER (ORDER BY ms.SalesMonth) AS PreviousMonthSales,
    ms.MonthlyTotal - LAG(ms.MonthlyTotal, 1, 0) OVER (ORDER BY ms.SalesMonth) AS GrowthAmount,
    CASE
        WHEN LAG(ms.MonthlyTotal, 1, 0) OVER (ORDER BY ms.SalesMonth) > 0
        THEN (ms.MonthlyTotal - LAG(ms.MonthlyTotal, 1, 0) OVER (ORDER BY ms.SalesMonth)) / LAG(ms.MonthlyTotal, 1, 0) OVER (ORDER BY ms.SalesMonth) * 100
        ELSE NULL
    END AS GrowthPercentage
FROM MonthlySales AS ms
ORDER BY ms.SalesMonth;

--------------------------------------------------------------------------------

WITH CustomerTotalPurchases AS (
    SELECT
        c.CustomerID,
        p.FirstName + N' ' + p.LastName AS CustomerName,
        SUM(soh.TotalDue) AS TotalPurchases
    FROM Sales.Customer AS c
    JOIN Person.Person AS p ON c.PersonID = p.BusinessEntityID
    JOIN Sales.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
    GROUP BY c.CustomerID, p.FirstName, p.LastName
)
SELECT
    ctp.CustomerName,
    ctp.TotalPurchases,
    NTILE(4) OVER (ORDER BY ctp.TotalPurchases DESC) AS Quartile,
    AVG(ctp.TotalPurchases) OVER (PARTITION BY NTILE(4) OVER (ORDER BY ctp.TotalPurchases DESC)) AS QuartileAverage
FROM CustomerTotalPurchases AS ctp
ORDER BY ctp.TotalPurchases DESC;
------------------------------------------------------------
SELECT ProductCategory,
    [2011], [2012], [2013], [2014],
    [2011] + [2012] + [2013] + [2014] AS TotalSales
FROM (
    SELECT
        pc.Name AS ProductCategory,
        YEAR(soh.OrderDate) AS SalesYear,
        SUM(sod.OrderQty * sod.UnitPrice) AS SalesAmount
    FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
    JOIN Production.Product AS p ON sod.ProductID = p.ProductID
    JOIN Production.ProductSubcategory AS ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    JOIN Production.ProductCategory AS pc ON ps.ProductCategoryID = pc.ProductCategoryID
    WHERE YEAR(soh.OrderDate) IN (2011, 2012, 2013, 2014)
    GROUP BY pc.Name, YEAR(soh.OrderDate)
) AS SourceTable
PIVOT (
    SUM(SalesAmount)
    FOR SalesYear IN ([2011], [2012], [2013], [2014])
) AS PivotTable
ORDER BY ProductCategory;

------------------------------------------------------------

SELECT Department,
    ISNULL(Male, 0) AS MaleCount,
    ISNULL(Female, 0) AS FemaleCount,
    ISNULL(Male, 0) + ISNULL(Female, 0) AS TotalCount
FROM (
    SELECT
        d.Name AS Department,
        e.Gender,
        COUNT(e.BusinessEntityID) AS EmployeeCount
    FROM HumanResources.Employee AS e
    JOIN HumanResources.EmployeeDepartmentHistory AS edh ON e.BusinessEntityID = edh.BusinessEntityID
    JOIN HumanResources.Department AS d ON edh.DepartmentID = d.DepartmentID
    WHERE edh.EndDate IS NULL -- Current department
    GROUP BY d.Name, e.Gender
) AS SourceTable
PIVOT (
    SUM(EmployeeCount)
    FOR Gender IN ([M], [F])
) AS PivotTable
ORDER BY Department;


------------------------------------------------------------
DECLARE @cols AS NVARCHAR(MAX),
    @query AS NVARCHAR(MAX);

SELECT @cols = STUFF((SELECT DISTINCT 
                            
                            QUOTENAME(CAST(YEAR(OrderDate) AS NVARCHAR(4)) + N'Q' + CAST(DATEPART(qq, OrderDate) AS NVARCHAR(1)))
                      FROM Sales.SalesOrderHeader
                      ORDER BY 1
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'');

SET @query = N'SELECT ProductCategory, ' + @cols + N' FROM 
             (
                SELECT 
                    pc.Name AS ProductCategory,
                    CAST(YEAR(soh.OrderDate) AS NVARCHAR(4)) + N''Q'' + CAST(DATEPART(qq, soh.OrderDate) AS NVARCHAR(1)) AS SalesQuarter,
                    SUM(sod.OrderQty * sod.UnitPrice) AS SalesAmount
                FROM Sales.SalesOrderHeader AS soh
                JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
                JOIN Production.Product AS p ON sod.ProductID = p.ProductID
                JOIN Production.ProductSubcategory AS ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
                JOIN Production.ProductCategory AS pc ON ps.ProductCategoryID = pc.ProductCategoryID
                GROUP BY pc.Name, YEAR(soh.OrderDate), DATEPART(qq, soh.OrderDate)
            ) AS SourceTable
            PIVOT 
            (
                SUM(SalesAmount)
                FOR SalesQuarter IN (' + @cols + N')
            ) AS PivotTable
            ORDER BY ProductCategory;'

EXEC sp_executesql @query;
--------------------------------------------------------------------------------

-- 
SELECT ProductID, Name
FROM Production.Product
WHERE ProductID IN (
    SELECT DISTINCT sod.ProductID
    FROM Sales.SalesOrderDetail AS sod
    JOIN Sales.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
    WHERE YEAR(soh.OrderDate) = 2013
)
INTERSECT
SELECT ProductID, Name
FROM Production.Product
WHERE ProductID IN (
    SELECT DISTINCT sod.ProductID
    FROM Sales.SalesOrderDetail AS sod
    JOIN Sales.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
    WHERE YEAR(soh.OrderDate) = 2014
);

-- --------------------------------------------------------------------------------
SELECT ProductID, Name
FROM Production.Product
WHERE ProductID IN (
    SELECT DISTINCT sod.ProductID
    FROM Sales.SalesOrderDetail AS sod
    JOIN Sales.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
    WHERE YEAR(soh.OrderDate) = 2013
)
EXCEPT
SELECT ProductID, Name
FROM Production.Product
WHERE ProductID IN (
    SELECT DISTINCT sod.ProductID
    FROM Sales.SalesOrderDetail AS sod
    JOIN Sales.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
    WHERE YEAR(soh.OrderDate) = 2014
);
------------------------------------------------------------
-- 
SELECT DISTINCT pc.Name AS ProductCategory
FROM Production.Product AS p
JOIN Production.ProductSubcategory AS ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory AS pc ON ps.ProductCategoryID = pc.ProductCategoryID
WHERE p.ListPrice > 1000

INTERSECT
------------------------------------------------------------
-- 
SELECT DISTINCT pc.Name AS ProductCategory
FROM Production.Product AS p
JOIN Production.ProductSubcategory AS ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN Production.ProductCategory AS pc ON ps.ProductCategoryID = pc.ProductCategoryID
JOIN Sales.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID
GROUP BY pc.Name
HAVING SUM(sod.OrderQty) > 1000;
------------------------------------------------------------
-------------------------
DECLARE @CurrentYear INT = YEAR(GETDATE());
DECLARE @TotalSales MONEY;
DECLARE @AverageOrderValue MONEY;

SELECT
    @TotalSales = SUM(TotalDue),
    @AverageOrderValue = AVG(TotalDue)
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = @CurrentYear;

SELECT
    N'Current Year: ' + CAST(@CurrentYear AS NVARCHAR(4)) AS Statistic,
    N'Total Sales: ' + FORMAT(@TotalSales, 'C', 'en-us') AS Value
UNION ALL
SELECT
    N'Average Order Value: ',
    FORMAT(@AverageOrderValue, 'C', 'en-us');
    --------------------------------------------------------------------------------
    --
DECLARE @ProductID INT = 777; --
DECLARE @ProductName NVARCHAR(50);

SELECT @ProductName = Name FROM Production.Product WHERE ProductID = @ProductID;

IF @ProductName IS NOT NULL
BEGIN
    SELECT N'Product Exists: ' + @ProductName AS Status;
    SELECT ProductID, Name, ProductNumber, ListPrice FROM Production.Product WHERE ProductID = @ProductID;
END
ELSE
BEGIN
    SELECT N'Product Not Found. Suggesting similar products:' AS Status;
    SELECT TOP 5 ProductID, Name, ProductNumber, ListPrice
    FROM Production.Product
    WHERE ProductSubcategoryID = (SELECT ProductSubcategoryID FROM Production.Product WHERE ProductID = @ProductID) -- حاول العثور على فئة فرعية مماثلة
    ORDER BY NEWID(); -- 
END;
--------------------------------------------------------------------------------

DECLARE @Month INT = 1;
DECLARE @Year INT = 2013;

WHILE @Month <= 12
BEGIN
    SELECT
        DATENAME(month, DATEFROMPARTS(@Year, @Month, 1)) AS SalesMonth,
        SUM(TotalDue) AS MonthlySales
    FROM Sales.SalesOrderHeader
    WHERE YEAR(OrderDate) = @Year AND MONTH(OrderDate) = @Month
    GROUP BY MONTH(OrderDate);

    SET @Month = @Month + 1;


BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @ProductIDToUpdate INT = 777;
    DECLARE @NewPrice MONEY = 0; -- 

    IF @NewPrice <= 0
    BEGIN
        RAISERROR (N'New price must be greater than zero.', 16, 1);
    END;

    UPDATE Production.Product
    SET ListPrice = @NewPrice
    WHERE ProductID = @ProductIDToUpdate;

    COMMIT TRANSACTION;
    PRINT N'Product price updated successfully.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT N'Error updating product price: ' + ERROR_MESSAGE();
END CATCH;
----------------------------------------------------------------------------------------------------
CREATE FUNCTION Sales.CalculateCustomerLifetimeValue (
    @CustomerID INT,
    @StartDate DATE,
    @EndDate DATE,
    @ActivityWeight DECIMAL(5,2) -- 
)
RETURNS MONEY
AS
BEGIN
    DECLARE @TotalAmountSpent MONEY;
    DECLARE @RecentActivityValue MONEY;
    DECLARE @CLV MONEY;
    --------------------------------------------------------------------------------
    -- 
    SELECT @TotalAmountSpent = SUM(TotalDue)
    FROM Sales.SalesOrderHeader
    WHERE CustomerID = @CustomerID
      AND OrderDate BETWEEN @StartDate AND @EndDate;

    -- 
    ----------------------------------------------------------------------------------------------------


    -- 
    SELECT @RecentActivityValue = SUM(TotalDue)
    FROM Sales.SalesOrderHeader
    WHERE CustomerID = @CustomerID
      AND OrderDate >= DATEADD(month, -3, GETDATE()); -- 

    -- --------------------------------------------------------------------------------
    SET @CLV = ISNULL(@TotalAmountSpent, 0) * (1 - @ActivityWeight) + ISNULL(@RecentActivityValue, 0) * @ActivityWeight;

    RETURN @CLV;
END;
--------------------------------------------------------------------------------
CREATE FUNCTION Production.GetProductsByPriceAndCategory (
    @MinPrice MONEY,
    @MaxPrice MONEY,
    @CategoryName NVARCHAR(50)
)
RETURNS @Products TABLE (
    ProductID INT,
    ProductName NVARCHAR(50),
    ProductNumber NVARCHAR(25),
    ListPrice MONEY,
    CategoryName NVARCHAR(50)
)
AS
BEGIN
    IF @MinPrice < 0 OR @MaxPrice < 0 OR @MinPrice > @MaxPrice
    BEGIN
        RAISERROR (N'Invalid price range. MinPrice and MaxPrice must be positive, and MinPrice must be less than or equal to MaxPrice.', 16, 1);
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM Production.ProductCategory WHERE Name = @CategoryName)
    BEGIN
        RAISERROR (N'Category name does not exist.', 16, 1);
        RETURN;
    END;

    INSERT INTO @Products (ProductID, ProductName, ProductNumber, ListPrice, CategoryName)
    SELECT
        p.ProductID,
        p.Name,
        p.ProductNumber,
        p.ListPrice,
        pc.Name
    FROM Production.Product AS p
    JOIN Production.ProductSubcategory AS ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    JOIN Production.ProductCategory AS pc ON ps.ProductCategoryID = pc.ProductCategoryID
    WHERE p.ListPrice BETWEEN @MinPrice AND @MaxPrice
      AND pc.Name = @CategoryName;

    RETURN;

    --------------------------------------------------------------------------------
CREATE FUNCTION HumanResources.GetEmployeesUnderManager (
    @ManagerBusinessEntityID INT
)
RETURNS TABLE
AS
RETURN
(
    WITH EmployeeHierarchy AS (
        SELECT
            e.BusinessEntityID,
            p.FirstName + N' ' + p.LastName AS EmployeeName,
            e.OrganizationNode,
            e.OrganizationNode.GetLevel() AS HierarchyLevel
        FROM HumanResources.Employee AS e
        JOIN Person.Person AS p ON e.BusinessEntityID = p.BusinessEntityID
        WHERE e.BusinessEntityID = @ManagerBusinessEntityID

        UNION ALL

        SELECT
            e.BusinessEntityID,
            p.FirstName + N' ' + p.LastName AS EmployeeName,
            e.OrganizationNode,
            e.OrganizationNode.GetLevel() AS HierarchyLevel
        FROM HumanResources.Employee AS e
        JOIN Person.Person AS p ON e.BusinessEntityID = p.BusinessEntityID
        JOIN EmployeeHierarchy AS eh ON e.OrganizationNode.IsDescendantOf(eh.OrganizationNode) = 1
        WHERE e.BusinessEntityID <> @ManagerBusinessEntityID
    )
    SELECT
        eh.EmployeeName,
        (SELECT p.FirstName + N' ' + p.LastName FROM HumanResources.Employee AS mgr_e JOIN Person.Person AS mgr_p ON mgr_e.BusinessEntityID = mgr_p.BusinessEntityID WHERE mgr_e.OrganizationNode = eh.OrganizationNode.GetAncestor(1)) AS ManagerName,
        eh.HierarchyLevel,
        eh.OrganizationNode.ToString() AS EmployeePath
    FROM EmployeeHierarchy AS eh
);
------------------------------------------------------------

CREATE PROCEDURE Production.GetProductsByCategoryAndPrice
    @CategoryName NVARCHAR(50),
    @MinPrice MONEY = NULL,
    @MaxPrice MONEY = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- 
    IF @MinPrice IS NOT NULL AND @MinPrice < 0
    BEGIN
        RAISERROR (N'MinPrice cannot be negative.', 16, 1);
        RETURN;
    END;

    IF @MaxPrice IS NOT NULL AND @MaxPrice < 0
    BEGIN
        RAISERROR (N'MaxPrice cannot be negative.', 16, 1);
        RETURN;
    END;

    IF @MinPrice IS NOT NULL AND @MaxPrice IS NOT NULL AND @MinPrice > @MaxPrice
    BEGIN
        RAISERROR (N'MinPrice cannot be greater than MaxPrice.', 16, 1);
        RETURN;
    END;

    SELECT
        p.ProductID,
        p.Name AS ProductName,
        p.ProductNumber,
        p.ListPrice,
        pc.Name AS CategoryName
    FROM Production.Product AS p
    JOIN Production.ProductSubcategory AS ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    JOIN Production.ProductCategory AS pc ON ps.ProductCategoryID = pc.ProductCategoryID
    WHERE pc.Name = @CategoryName
      AND (@MinPrice IS NULL OR p.ListPrice >= @MinPrice)
      AND (@MaxPrice IS NULL OR p.ListPrice <= @MaxPrice)
    ORDER BY p.ListPrice;
END;

----------------------------------------------------------------------------------------------------
CREATE PROCEDURE Production.UpdateProductPricing
    @ProductID INT,
    @NewListPrice MONEY,
    @UpdatedBy NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @OldListPrice MONEY;

        -- 
        SELECT @OldListPrice = ListPrice FROM Production.Product WHERE ProductID = @ProductID;
        IF @OldListPrice IS NULL
        BEGIN
            RAISERROR (N'Product with specified ProductID does not exist.', 16, 1);
        END;

        -- 
        IF @NewListPrice <= 0
        BEGIN
            RAISERROR (N'New ListPrice must be greater than zero.', 16, 1);
        END;

        -- 
        UPDATE Production.Product
        SET ListPrice = @NewListPrice,
            ModifiedDate = GETDATE()
        WHERE ProductID = @ProductID;

        -- 
        -- CREATE TABLE Production.ProductPriceAudit (
        --    AuditID INT IDENTITY(1,1) PRIMARY KEY,
        --    ProductID INT,
        --    OldListPrice MONEY,
        --    NewListPrice MONEY,
        --    UpdatedBy NVARCHAR(50),
        --    UpdatedDate DATETIME DEFAULT GETDATE()
        -- );
        INSERT INTO Production.ProductPriceAudit (ProductID, OldListPrice, NewListPrice, UpdatedBy)
        VALUES (@ProductID, @OldListPrice, @NewListPrice, @UpdatedBy);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;

CREATE PROCEDURE Sales.GenerateComprehensiveSalesReport
    @StartDate DATE,
    @EndDate DATE,
    @TerritoryID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- 
    IF @StartDate IS NULL OR @EndDate IS NULL OR @StartDate > @EndDate
    BEGIN
        RAISERROR (N'Invalid date range. StartDate and EndDate are required, and StartDate must be less than or equal to EndDate.', 16, 1);
        RETURN;
    END;

    -- 
    SELECT
        COUNT(soh.SalesOrderID) AS TotalOrders,
        SUM(soh.TotalDue) AS TotalSalesAmount,
        AVG(soh.TotalDue) AS AverageOrderValue,
        COUNT(DISTINCT soh.CustomerID) AS UniqueCustomers
    FROM Sales.SalesOrderHeader AS soh
    WHERE soh.OrderDate BETWEEN @StartDate AND @EndDate
      AND (@TerritoryID IS NULL OR soh.TerritoryID = @TerritoryID);

    -- 
    SELECT
        soh.SalesOrderID,
        soh.OrderDate,
        soh.TotalDue,
        p.FirstName + N' ' + p.LastName AS CustomerName,
        st.Name AS SalesTerritory,
        prod.Name AS ProductName,
        sod.OrderQty,
        sod.UnitPrice,
        sod.LineTotal
    FROM Sales.SalesOrderHeader AS soh
    JOIN Sales.Customer AS c ON soh.CustomerID = c.CustomerID
    JOIN Person.Person AS p ON c.PersonID = p.BusinessEntityID
    JOIN Sales.SalesTerritory AS st ON soh.TerritoryID = st.TerritoryID
    JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
    JOIN Production.Product AS prod ON sod.ProductID = prod.ProductID
    WHERE soh.OrderDate BETWEEN @StartDate AND @EndDate
      AND (@TerritoryID IS NULL OR soh.TerritoryID = @TerritoryID)
    ORDER BY soh.OrderDate, soh.SalesOrderID;
END;

CREATE PROCEDURE Sales.ProcessBulkOrdersFromXml
    @OrderXml XML
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 
        DECLARE @TempOrders TABLE (
            CustomerID INT,
            OrderDate DATETIME,
            DueDate DATETIME,
            ShipDate DATETIME,
            Status TINYINT,
            SalesOrderNumber NVARCHAR(25),
            PurchaseOrderNumber NVARCHAR(25),
            AccountNumber NVARCHAR(15),
            BillToAddressID INT,
            ShipToAddressID INT,
            ShipMethodID INT,
            SubTotal MONEY,
            TaxAmt MONEY,
            Freight MONEY,
            Comment NVARCHAR(128)
        );

        -- 
        INSERT INTO @TempOrders (
            CustomerID, OrderDate, DueDate, ShipDate, Status, SalesOrderNumber, PurchaseOrderNumber, AccountNumber,
            BillToAddressID, ShipToAddressID, ShipMethodID, SubTotal, TaxAmt, Freight, Comment
        )
        SELECT
            T.Item.value('(CustomerID)[1]', 'INT'),
            T.Item.value('(OrderDate)[1]', 'DATETIME'),
            T.Item.value('(DueDate)[1]', 'DATETIME'),
            T.Item.value('(ShipDate)[1]', 'DATETIME'),
            T.Item.value('(Status)[1]', 'TINYINT'),
            T.Item.value('(SalesOrderNumber)[1]', 'NVARCHAR(25)'),
            T.Item.value('(PurchaseOrderNumber)[1]', 'NVARCHAR(25)'),
            T.Item.value('(AccountNumber)[1]', 'NVARCHAR(15)'),
            T.Item.value('(BillToAddressID)[1]', 'INT'),
            T.Item.value('(ShipToAddressID)[1]', 'INT'),
            T.Item.value('(ShipMethodID)[1]', 'INT'),
            T.Item.value('(SubTotal)[1]', 'MONEY'),
            T.Item.value('(TaxAmt)[1]', 'MONEY'),
            T.Item.value('(Freight)[1]', 'MONEY'),
            T.Item.value('(Comment)[1]', 'NVARCHAR(128)')
        FROM @OrderXml.nodes('/Orders/Order') AS T(Item);

        -- 
        INSERT INTO Sales.SalesOrderHeader (
            RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, SalesOrderNumber, PurchaseOrderNumber, AccountNumber,
            CustomerID, SalesPersonID, TerritoryID, BillToAddressID, ShipToAddressID, ShipMethodID, CreditCardID, CurrencyRateID,
            SubTotal, TaxAmt, Freight, TotalDue, Comment, rowguid, ModifiedDate
        )
        SELECT
            
            to.OrderDate, to.DueDate, to.ShipDate, to.Status, 1, to.SalesOrderNumber, to.PurchaseOrderNumber, to.AccountNumber,
            to.CustomerID, NULL, NULL, to.BillToAddressID, to.ShipToAddressID, to.ShipMethodID, NULL, NULL,
            to.SubTotal, to.TaxAmt, to.Freight, (to.SubTotal + to.TaxAmt + to.Freight), to.Comment, NEWID(), GETDATE()
        FROM @TempOrders AS to;

        COMMIT TRANSACTION;

        SELECT N'Bulk orders processed successfully.' AS StatusMessage;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;


CREATE PROCEDURE Production.FlexibleProductSearch
    @ProductName NVARCHAR(50) = NULL,
    @CategoryName NVARCHAR(50) = NULL,
    @MinPrice MONEY = NULL,
    @MaxPrice MONEY = NULL,
    @MinSellStartDate DATE = NULL,
    @MaxSellStartDate DATE = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @TotalCount INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- 
    IF @PageNumber < 1
        SET @PageNumber = 1;
    IF @PageSize < 1
        SET @PageSize = 10;

    -- 
    SELECT @TotalCount = COUNT(p.ProductID)
    FROM Production.Product AS p
    LEFT JOIN Production.ProductSubcategory AS ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    LEFT JOIN Production.ProductCategory AS pc ON ps.ProductCategoryID = pc.ProductCategoryID
    WHERE (@ProductName IS NULL OR p.Name LIKE '%' + @ProductName + '%')
      AND (@CategoryName IS NULL OR pc.Name = @CategoryName)
      AND (@MinPrice IS NULL OR p.ListPrice >= @MinPrice)
      AND (@MaxPrice IS NULL OR p.ListPrice <= @MaxPrice)
      AND (@MinSellStartDate IS NULL OR p.SellStartDate >= @MinSellStartDate)
      AND (@MaxSellStartDate IS NULL OR p.SellStartDate <= @MaxSellStartDate);

    -- 
    SELECT
        p.ProductID,
        p.Name AS ProductName,
        p.ProductNumber,
        p.ListPrice,
        pc.Name AS CategoryName,
        ps.Name AS SubcategoryName,
        p.SellStartDate
    FROM Production.Product AS p
    LEFT JOIN Production.ProductSubcategory AS ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    LEFT JOIN Production.ProductCategory AS pc ON ps.ProductCategoryID = pc.ProductCategoryID
    WHERE (@ProductName IS NULL OR p.Name LIKE '%' + @ProductName + '%')
      AND (@CategoryName IS NULL OR pc.Name = @CategoryName)
      AND (@MinPrice IS NULL OR p.ListPrice >= @MinPrice)
      AND (@MaxPrice IS NULL OR p.ListPrice <= @MaxPrice)
      AND (@MinSellStartDate IS NULL OR p.SellStartDate >= @MinSellStartDate)
      AND (@MaxSellStartDate IS NULL OR p.SellStartDate <= @MaxSellStartDate)
    ORDER BY p.Name
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;





CREATE TRIGGER Sales.trg_UpdateProductInventoryAndSalesStats
ON Sales.SalesOrderDetail
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 
        UPDATE p
        SET p.Quantity = p.Quantity - i.OrderQty
        FROM Production.ProductInventory AS p
        JOIN inserted AS i ON p.ProductID = i.ProductID
        WHERE p.LocationID = 50; -- 

    
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
```




-- CREATE VIEW Sales.CustomerProductOrders AS
-- SELECT
--    c.CustomerID,
--    p.FirstName + N' ' + p.LastName AS CustomerName,
--    prod.ProductID,
--    prod.Name AS ProductName,
--    sod.OrderQty,
--    sod.UnitPrice,
--    soh.OrderDate
-- FROM Sales.SalesOrderHeader AS soh
-- JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
-- JOIN Sales.Customer AS c ON soh.CustomerID = c.CustomerID
-- JOIN Person.Person AS p ON c.PersonID = p.BusinessEntityID
-- JOIN Production.Product AS prod ON sod.ProductID = prod.ProductID;

CREATE TRIGGER Sales.trg_InsteadOfInsertCustomerProductOrders
ON Sales.CustomerProductOrders
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        --
        INSERT INTO Sales.SalesOrderHeader (
            RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, SalesOrderNumber, PurchaseOrderNumber, AccountNumber,
            CustomerID, SalesPersonID, TerritoryID, BillToAddressID, ShipToAddressID, ShipMethodID, CreditCardID, CurrencyRateID,
            SubTotal, TaxAmt, Freight, TotalDue, Comment, rowguid, ModifiedDate
        )
        SELECT
            1, GETDATE(), GETDATE(), GETDATE(), 1, 1, NEWID(), NULL, NULL,
            i.CustomerID, NULL, NULL, NULL, NULL, 1, NULL, NULL,
            i.OrderQty * i.UnitPrice, 0, 0, i.OrderQty * i.UnitPrice, NULL, NEWID(), GETDATE()
        FROM inserted AS i;

        -- إدراج في Sales.SalesOrderDetail
        INSERT INTO Sales.SalesOrderDetail (
            SalesOrderID, OrderQty, ProductID, UnitPrice, UnitPriceDiscount, LineTotal, rowguid, ModifiedDate
        )
        SELECT
            (SELECT MAX(SalesOrderID) FROM Sales.SalesOrderHeader WHERE CustomerID = i.CustomerID), -- افتراض بسيط، قد يحتاج إلى منطق أكثر تعقيدًا
            i.OrderQty,
            i.ProductID,
            i.UnitPrice,
            0, -- UnitPriceDiscount
            i.OrderQty * i.UnitPrice,
            NEWID(), GETDATE()
        FROM inserted AS i;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;




CREATE TRIGGER Production.trg_ProductPriceAudit
ON Production.Product
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(ListPrice)
    BEGIN
        INSERT INTO Production.ProductPriceAudit (
            ProductID, OldListPrice, NewListPrice, UpdatedBy, UpdatedDate
        )
        SELECT
            i.ProductID,
            d.ListPrice,
            i.ListPrice,
            SUSER_SNAME(), -- 
            GETDATE()
        FROM inserted AS i
        JOIN deleted AS d ON i.ProductID = d.ProductID
        WHERE i.ListPrice <> d.ListPrice;
    END;
END;





-- 
CREATE NONCLUSTERED INDEX IX_Product_ActiveProducts
ON Production.Product (ProductID, Name, ListPrice)
WHERE SellEndDate IS NULL;

-- 
CREATE NONCLUSTERED INDEX IX_SalesOrderHeader_RecentOrders
ON Sales.SalesOrderHeader (OrderDate, SalesOrderID, CustomerID, TotalDue)
WHERE OrderDate >= DATEADD(year, -2, GETDATE());



