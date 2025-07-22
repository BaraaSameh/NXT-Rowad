--Create a non-clustered index on the email column in the sales.customers table to improve search performance when looking up customers by email.

create NONCLUSTERED  index i_customer
on [Sales].[Customer](email)

create NONCLUSTERED  index ix_customer
on [Person].[Person]([EmailPromotion])


--Create a composite index on the production.products table that includes category_id and brand_id columns to optimize searches that filter by both category and brand.
create NONCLUSTERED  index iv_customer
on [Production].[Product]([ProductSubcategoryID],[ProductModelID])

--Create an index on sales.orders table for the order_date column and include customer_id, store_id, and order_status as included columns to improve reporting queries
	create nonclustered index vi_customer
	on [Sales].[SalesOrderHeader]-- ([OrderDate])
	include ([CustomerID],[TerritoryID],[Status])

	CREATE NONCLUSTERED INDEX v_customer
ON [Sales].[SalesOrderHeader] ([OrderDate])
INCLUDE ([CustomerID], [TerritoryID], [Status]);

-- starrt with triggers 
-- Customer activity log
CREATE TABLE sales.customer_log (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT,
    action VARCHAR(50),
    log_date DATETIME DEFAULT GETDATE()
);

-- Price history tracking
CREATE TABLE production.price_history (
    history_id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT,
    old_price DECIMAL(10,2),
    new_price DECIMAL(10,2),
    change_date DATETIME DEFAULT GETDATE(),
    changed_by VARCHAR(100)
);

-- Order audit trail
CREATE TABLE sales.order_audit (
    audit_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT,
    customer_id INT,
    store_id INT,
    staff_id INT,
    order_date DATE,
    audit_timestamp DATETIME DEFAULT GETDATE()
);
--

---.Create a trigger that automatically inserts a welcome record into a customer_log table whenever a new customer is added to sales.customers. (First create the log table, then the trigger)

create trigger trgv1
on [Sales].[Customer]
after insert 
as 
begin 
INSERT INTO sales.customer_log (customer_id, action)
    SELECT [CustomerID], 'Welcome - New Customer'
    FROM inserted;
END;

--Create a trigger on production.products that logs any changes to the list_price column into a price_history table, storing the old price, new price, and change date.

create trigger vi on [Production].[Product]
after update 
as 
begin 
 INSERT INTO production.price_history (
        product_id,
        old_price,
        new_price,
        change_date,
        changed_by
    )
    SELECT
        d.[ProductID],
        d.[ListPrice] AS old_price,
        i.[ListPrice] AS new_price,
        GETDATE(),
        SYSTEM_USER
    FROM deleted d
    JOIN inserted i
        ON d.[ProductID] = i.[ProductID]
    WHERE d.[ListPrice] <> i.[ListPrice];
end

--Create an INSTEAD OF DELETE trigger on production.categories that prevents deletion of categories that have associated products. Display an appropriate error message.

--CREATE TRIGGER trg_PreventCategoryDelete
--ON [Production].[ProductCategory]
--INSTEAD OF DELETE
--AS
--BEGIN
--    IF EXISTS (
--        SELECT 1
--        FROM deleted d
--        JOIN [Production].[Product]p ON d.category_id = p.category_id
--    )
--    BEGIN
--        RAISERROR('Cannot delete category: associated products exist.', 16, 1);
--    END
--    ELSE
--    BEGIN
--        DELETE FROM [Production].[ProductCategory]
--        WHERE [ProductSubcategoryID] IN (SELECT [ProductSubcategoryID] FROM deleted);
--    END
--END;

--Create a trigger on sales.order_items that automatically reduces the quantity in production.stocks when a new order item is inserted

--create trigger vo 
--on [Sales].[SalesOrderDetail]
--after insert 
--as 
--begin 

--Create a trigger that logs all new orders into an order_audit table, capturing order details and the date/time when the record was created.

CREATE TRIGGER voo
ON [Sales].[SalesOrderHeader]
AFTER INSERT
AS
BEGIN
    INSERT INTO sales.order_audit (
        order_id,
        customer_id,
        store_id,
        staff_id,
        order_date
    )
    SELECT 
        i.[SalesOrderID],
        i.[CustomerID],
        i.[TerritoryID],
        i.[SalesPersonID],
        i.[OrderDate]
    FROM inserted i;
END;



