--*************************************************************************--
-- Title: Assignment07
-- Author: BMoran
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2017-01-01,BMoran,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_BMoran')
	 Begin 
	  Alter Database [Assignment07DB_BMoran] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_BMoran;
	 End
	Create Database Assignment07DB_BMoran;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_BMoran;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.
/* 
	1. Need ProductName, UnitPrice
	2. View that stores this data = vProducts
	3. UnitPrice field type = Money with constraint that it is >0 

Start with a simple select statement to get the data 
	SELECT ProductName, UnitPrice
	FROM vProducts
	ORDER BY ProductName; 
*/

-- Wrap in the FORMAT function to display Unite price as US dollars 

 SELECT
	ProductName
	,FORMAT (UnitPrice, 'C', 'en-us') AS UnitPrice
 FROM vProducts
 ORDER BY ProductName;
 GO

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.

/* 
	1. Need CategoryName, ProductName, Unit Price
	2. View(s) required: vCategories & vProducts
	3. Process steps
		- first select field names 
		- apply format function in select 
		- from categories view joined with products view on category ID 
		- apply order by CategoryName and Product Name 

Start with a simple select statement to get the data 
	SELECT CategoryName, ProductName, UnitPrice
	FROM vCategories as c INNER JOIN vProducts as p
	ON c.CategoryID = p.CategoryID
	ORDER BY CategoryName ASC, ProductName ASC;
*/

-- Wrap in the FORMAT function to display Unite price as US dollars 
SELECT 
	CategoryName
	,ProductName
	,FORMAT(UnitPrice, 'c', 'en-us') AS UnitPrice
FROM vCategories as c 
INNER JOIN vProducts as p
ON c.CategoryID = p.CategoryID
ORDER BY 
	CategoryName ASC, 
	ProductName ASC;
GO

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

/* 
	1. Need: ProductName, InventoryDate, UnitCount
	2. View(s) required: 
		- vProducts 
		- vInventories
	3. Process steps
		- select productname, Format inventoryDate, UnitCount
		- from vproducts join vinventories on product ID
		- then order by Product name and inventory date 

Start with a simple select statement to get the data 
SELECT p.ProductName, i.InventoryDate, i.[Count]
FROM vProducts as p 
INNER JOIN vInventories as i
ON p.ProductID = i.ProductID;


SELECT p.ProductName, i.InventoryDate, i.[Count]
FROM vProducts as p 
INNER JOIN vInventories as i
ON p.ProductID = i.ProductID;
GO

-- tried an intial format function but that does not get the right format 
SELECT 
	p.ProductName
	,FORMAT(i.InventoryDate, 'd', 'en-us') AS [Inventory Date]
	,i.[Count]
FROM vProducts as p 
INNER JOIN vInventories as i
ON p.ProductID = i.ProductID
ORDER BY
	p.ProductName ASC
	,i.inventoryDate ASC;
GO

-- need to convert to the Month, Year format like January, 2017
-- going to try to use DateName() and DatePart() to achieve 
--Option 1
SELECT 
	p.ProductName
	,[Inventory Date] = DATENAME(mm,i.InventoryDate) + ', ' + CAST(YEAR(i.inventoryDate) as nvarchar(50))
	,i.[Count]
FROM vProducts as p 
INNER JOIN vInventories as i
ON p.ProductID = i.ProductID
ORDER BY
	p.ProductName ASC
	,i.inventoryDate ASC;
GO
*/

-- trying a final version with concat to reduce code complexity and reduce multiple casts 
SELECT 
	p.ProductName
	,CONCAT(DATENAME(Month,i.InventoryDate), ', ', YEAR(i.InventoryDate)) AS InventoryDate
	,i.[Count] AS InventoryCount
FROM vProducts as p 
INNER JOIN vInventories as i
ON p.ProductID = i.ProductID
ORDER BY
	p.ProductName ASC
	,i.inventoryDate ASC;
GO


-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- problem is asking for the same output and info from # but wrapped into a view 
-- copied code from #3 and placed into syntax for creating a view 
CREATE or ALTER VIEW vProductInventories
AS
	SELECT TOP 1000000 
	p.ProductName
	,DATENAME(MM,i.InventoryDate) + ', ' + DATENAME(YY,i.InventoryDate) AS InventoryDate -- modifying the function type to keep date as something that can be ordered chronologically. The Concat worked initially but causes issues with calling data from views later. Adjusting in base problems to build on cleaner code 
	--,CONCAT(DATENAME(Month,i.InventoryDate), ', ', YEAR(i.InventoryDate)) as InventoryDate
	,i.[Count] AS InventoryCount
FROM vProducts as p 
INNER JOIN vInventories as i
ON p.ProductID = i.ProductID
ORDER BY
	p.ProductName ASC
	,MONTH(InventoryDate) ASC; -- needed to update order by to order month correctly chronologically
GO 

--SELECT * FROM vProductInventories; -- checked work and code matches answer key
--GO

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

/* 
	1. Need 
		-CategoryName
		-InventoryDate --> use concat function from #4
		-InventoryCount (Total --> SUM() function for grand TOTALS)
	2. View(s) required: 
		-vCategories
		-vInventories 
		-vProducts --> need to join categories to products to inventories to get categories and inventories linked
	3. Process steps
		- setup select statment 
		- need to join categories to products to inventories to get categories connected with inventories 
		- for date format we can use the same CONCAT function from #4
		- for grand total of count per category per date we can use the SUM() function
		- since we have columns not included in aggregate functions (e.g. CatName, Inv.Date) we must use them in GROUP BY before our ORDER BY

Start with a simple select statement to get the data 
SELECT C.CategoryName, i.InventoryDate, i.[Count]
FROM vCategories as c 
INNER JOIN vProducts as p
ON c.CategoryID = p.CategoryID
INNER JOIN vInventories as i 
ON p.ProductID = i.ProductID
ORDER BY c.CategoryName ASC, i.InventoryDate ASC; -- 
GO

-- Setup SELECT statement with functions 
SELECT 
	c.CategoryName
	,CONCAT(DATENAME(Month,i.InventoryDate), ', ', YEAR(i.InventoryDate)) as [Inventory Date] -- Swap out with select function from #4
	,SUM(i.[Count]) as [Inventory Count]
FROM vCategories as c 
INNER JOIN vProducts as p
ON c.CategoryID = p.CategoryID
INNER JOIN vInventories as i 
ON p.ProductID = i.ProductID
GROUP BY
	c.CategoryName
	,i.inventoryDate
ORDER BY
	c.CategoryName ASC -- question says order by product but orderin by product name yields the wrong answer -- shouldn't it be order by categoryname?
	,i.InventoryDate ASC; 
GO


SELECT 
	c.CategoryName
	,CONCAT(DATENAME(Month,i.InventoryDate), ', ', YEAR(i.InventoryDate)) as [Inventory Date] -- Swap out with select function from #4
	,SUM(i.[Count]) as [Inventory Count]
FROM vCategories as c 
INNER JOIN vProducts as p
ON c.CategoryID = p.CategoryID
INNER JOIN vInventories as i 
ON p.ProductID = i.ProductID
GROUP BY
	c.CategoryName
	,i.InventoryDate
ORDER BY
	c.CategoryName ASC -- question says order by product but orderin by product name yields the wrong answer -- shouldn't it be order by categoryname?
	,i.InventoryDate ASC; 
GO
*/

-- wrap select statement into desired VIEW 
CREATE or ALTER VIEW vCategoryInventories
AS
	SELECT TOP 1000000
		c.CategoryName
		,DATENAME(MM,i.InventoryDate) + ', ' + DATENAME(YY,i.InventoryDate) AS InventoryDate -- Adjusting based on the rationale from #4 
		--,CONCAT(DATENAME(Month,i.InventoryDate), ', ', YEAR(i.InventoryDate)) as [InventoryDate] -- 
		,SUM(i.[Count]) as [InventoryCount]
	FROM vCategories as c 
	INNER JOIN vProducts as p
	ON c.CategoryID = p.CategoryID
	INNER JOIN vInventories as i 
	ON p.ProductID = i.ProductID
	GROUP BY
		c.CategoryName -- not part of SUM() aggregate function and therefore must be grouped by 
		,i.inventoryDate -- CONCAT is not an aggregate function and therefore the i.inventorydate must be grouped by??
	ORDER BY
		c.CategoryName ASC -- question says order by product but orderin by product name yields the wrong answer -- shouldn't it be order by categoryname?
		,MONTH(i.InventoryDate) ASC; 
GO

-- Select * From vCategoryInventories; -- to check work 


-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviousMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view

-- Realized I needed to use the view from the previous proble so had to bake that in and re-do 
-- updating select statement and placing in view based on trial and error work below and changes made in problems above 

CREATE or ALTER VIEW vProductInventoriesWithPreviousMonthCounts
AS
	SELECT TOP 1000000
		ProductName
		,InventoryDate
		,InventoryCount
		,[PreviousMonthInventory] = LAG(InventoryCount, 1, 0) OVER (Partition by ProductName ORDER BY Month(InventoryDate))
	FROM vProductInventories
	ORDER BY 
		ProductName
		,CAST('01' + InventoryDate as date) ASC;
GO

-- SELECT * FROM vProductInventoriesWithPreviousMonthCounts;
-- GO

/* PREVIOUS WORK FOR 6 BEFORE STARTING OVER
	1. Need 
		-ProductName -- not in aggregate function must be grouped by 
		-InventoryDate -- use concat function from previous problems --> must be grouped by since it is not part of aggregrate function
		-[Count]
		-[Previous Month Count] --> LAG() may help us here initially before we account for NULLs
	2. View(s) required: 
		-vProducts
		-vInventories JOINED ON PROD ID 
	3. Process steps

-- setup initial select statements without functions applied to setup data structure
SELECT
	p.ProductName
	,i.InventoryDate
	,i.[Count] 
FROM vProducts as p 
INNER JOIN vInventories as i 
ON p.ProductID = i.ProductID
ORDER BY
	p.ProductName ASC, 
	i.InventoryDate ASC;
GO

-- update select statement to include function for inventory date and add lag function

SELECT
	p.ProductName
	,CONCAT(DATENAME(Month,i.InventoryDate), ', ', YEAR(i.InventoryDate)) as [Inventory Date] -- use concat function from 4 with alias 
	,i.[Count] AS [Inventory Count] -- alias added for better readability with lag function added 
	,[Previous Month Inventory] = LAG(i.[Count], 1, 0) OVER (PARTITION BY p.ProductID ORDER BY i.InventoryDate) -- using the optional offset element of the LAG syntax to account for Nulls
FROM vProducts as p 
INNER JOIN vInventories as i 
ON p.ProductID = i.ProductID
ORDER BY
	p.ProductName ASC, 
	i.InventoryDate ASC;
GO


-- Wrap final select statement into a view 
CREATE or ALTER VIEW vProductInventoriesWithPreviousMonthCounts
AS
	SELECT TOP 1000000
	p.ProductName
	,CONCAT(DATENAME(Month,i.InventoryDate), ', ', YEAR(i.InventoryDate)) as [Inventory Date] -- use concat function from 4 with alias 
	,i.[Count] AS [Inventory Count] -- alias added for better readability with lag function added 
	,[Previous Month Inventory] = LAG(i.[Count], 1, 0) OVER (PARTITION BY p.ProductID ORDER BY i.InventoryDate) -- using the optional offset element of the LAG syntax to account for Nulls
FROM vProducts as p 
INNER JOIN vInventories as i 
ON p.ProductID = i.ProductID
ORDER BY
	p.ProductName ASC, 
	i.InventoryDate ASC;
GO
*/


-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.

-- start with select statement from previous problem to build KPIs onto 
-- then wrapped create view around the setup SELECT statement 

CREATE or ALTER VIEW vProductInventoriesWithPreviousMonthCountsWithKPIs
AS
	SELECT TOP 100000
		ProductName,
		InventoryDate, 
		InventoryCount,
		PreviousMonthInventory,
		[CountVsPreviousCountKPI] = ISNULL(CASE -- adding ISNULL for error handling and to prevent null values from ever being returned 
			WHEN InventoryCount > PreviousMonthInventory Then 1 -- following taxonomy from "using functions for reporting" section of class notes
			WHEN InventoryCount = PreviousMonthInventory Then 0
			WHEN InventoryCount < PreviousMonthInventory Then -1
			END, 0)
	FROM vProductInventoriesWithPreviousMonthCounts
GO

-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
--Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
--go

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --

CREATE or ALTER Function fProductInventoriesWithPreviousMonthCountsWithKPIs
(@KPIValue int) -- inserting for parameters 
Returns Table -- defining return format 
AS
	Return SELECT 
		ProductName,
		InventoryDate,
		InventoryCount,
		PreviousMonthInventory, 
		CountVsPreviousCountKPI
		FROM vProductInventoriesWithPreviousMonthCountsWithKPIs -- calling latest view created in #7 per question ask 
		WHERE [CountVsPreviousCountKPI] = @KPIValue -- sets the match of the user input parameter to the where condition on the KPI column we want to match 
go


/*Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
*/
go

/***************************************************************************************/