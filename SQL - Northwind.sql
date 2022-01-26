USE Northwind
GO


-- 1. Which shippers do we have?
SELECT *
FROM Shippers;


-- 2. Certain fields from Categories
SELECT CategoryName, 
	Description
FROM Categories;


-- 3. Sales Representatives
SELECT FirstName, 
	LastName, 
	HireDate
FROM Employees
WHERE Title = 'Sales Representative';


-- 4. Sales Representatives in the United States
SELECT FirstName, 
	LastName, 
	HireDate
FROM Employees
WHERE Title = 'Sales Representative'
AND Country = 'USA';


-- 5. Orders placed by specific EmployeeID
SELECT OrderID, 
	OrderDate
FROM Orders
WHERE EmployeeID = 5;


-- 6. Suppliers and ContactTitles
SELECT SupplierID, 
	ContactName, 
	ContactTitle
FROM Suppliers
WHERE ContactTitle <> 'Marketing Manager';


-- 7. Products with “queso” in ProductName
SELECT ProductID, 
	ProductName
FROM Products
WHERE ProductName LIKE '%queso%';


-- 8. Orders shipping to France or Belgium
SELECT OrderID, 
	CustomerID, 
	ShipCountry
FROM Orders
WHERE ShipCountry = 'France' OR ShipCountry = 'Belgium';


-- 9. Orders shipping to any country in Latin America
SELECT OrderID, 
	CustomerID, 
	ShipCountry
FROM Orders
WHERE ShipCountry IN ('Brazil', 'Mexico', 'Argentina', 'Venezuela');


-- 10. Employees, in order of age
SELECT FirstName, 
	LastName, 
	Title, 
	BirthDate
FROM Employees
ORDER BY BirthDate;


-- 11. Showing only the Date with a DateTime field
SELECT FirstName, 
	LastName, 
	Title, 
	CONVERT(Date, BirthDate) AS DateOnlyBirthDate
FROM Employees
ORDER BY BirthDate;


-- 12. Employees full name
SELECT FirstName, 
	LastName, 
	CONCAT(FirstName, ' ', LastName) AS FullName
FROM Employees;


-- 13. OrderDetails amount per line item
SELECT OrderID,
	ProductID,
	UnitPrice
	Quantity,
	UnitPrice * Quantity AS TotalPrice
FROM OrderDetails;


-- 14. How many customers?
SELECT COUNT(DISTINCT CustomerID) AS TotalCustomers
FROM Customers;


-- 15. When was the first order?
SELECT MIN(OrderDate) AS FirstOrder
FROM Orders;


-- 16. Countries where there are customers
SELECT DISTINCT Country
FROM Customers;


-- 17. Contact titles for customers
SELECT ContactTitle, 
	COUNT(ContactTitle) AS TotalContactTitle
FROM Customers
GROUP BY ContactTitle;


-- 18. Products with associated supplier names
SELECT ProductID,
	ProductName,
	CompanyName
FROM Products
	JOIN Suppliers
		ON Products.SupplierID = Suppliers.SupplierID
ORDER BY ProductID;


-- 19. Orders and the Shipper that was used
SELECT OrderID,
	CONVERT(Date, OrderDate),
	CompanyName
FROM Orders
	JOIN Shippers
		ON Orders.ShipVia = Shippers.ShipperID
WHERE OrderID < 10300
ORDER BY OrderID;


-- 20. Categories, and the total products in each category
SELECT CategoryName,
	COUNT(Products.CategoryID) AS TotalProducts
FROM Categories
	JOIN Products
		ON Categories.CategoryID = Products.CategoryID
GROUP BY CategoryName
ORDER BY TotalProducts DESC;


-- 21. Total customers per country/city
SELECT Country,
	City,
	COUNT(CustomerID) AS TotalCustomer
FROM Customers
GROUP BY Country, City
ORDER BY TotalCustomer DESC;


-- 22. Products that need reordering
SELECT ProductID,
	ProductName,
	UnitsInStock,
	ReorderLevel
FROM Products
WHERE UnitsInStock < ReorderLevel;


-- 23. Products that need reordering, continued
SELECT ProductID,
	ProductName,
	UnitsInStock,
	UnitsOnOrder,
	ReorderLevel,
	Discontinued
FROM Products
WHERE UnitsInStock + UnitsOnOrder <= ReorderLevel
AND Discontinued = 0;


-- 24. Customer list by region
SELECT CustomerID,
	CompanyName,
	Region
FROM Customers
ORDER BY 
	CASE 
		WHEN Region IS NULL THEN 1
		ELSE 0 
	END,
	Region,
	CustomerID;


-- 25. High freight charges
SELECT TOP(3) ShipCountry,
	AVG(Freight) AS AverageFreight
FROM Orders
GROUP BY ShipCountry
ORDER BY AverageFreight DESC;


-- 26. High freight charges - 2015
SELECT TOP(3) ShipCountry,
	AVG(Freight) AS AverageFreight
FROM Orders
WHERE YEAR(OrderDate) = 2015
GROUP BY ShipCountry
ORDER BY AverageFreight DESC;


-- 27. High freight charges with between
SELECT TOP(3) ShipCountry,
	AVG(Freight) AS AverageFreight
FROM Orders
WHERE OrderDate BETWEEN '2015-01-01' AND '2015-12-31'
GROUP BY ShipCountry
ORDER BY AverageFreight DESC;


-- 28. High freight charges - last year
SELECT TOP(3) ShipCountry,
	AVG(Freight) AS AverageFreight
FROM Orders
WHERE OrderDate >= DATEADD(YEAR, -1, (SELECT MAX(OrderDate) FROM Orders))
GROUP BY ShipCountry
ORDER BY AverageFreight DESC;


-- 29. Inventory list
SELECT Orders.EmployeeID,
	LastName,
	Orders.OrderID,
	ProductName,
	Quantity
FROM Employees
	JOIN Orders 
		ON Employees.EmployeeID = Orders.EmployeeID
	JOIN OrderDetails
		ON Orders.OrderID = OrderDetails.OrderID
	JOIN Products
		ON OrderDetails.ProductID = Products.ProductID
ORDER BY OrderID, Products.ProductID;


-- 30. Customers with no orders
SELECT Customers.CustomerID AS Customers_CustomerID,
	Orders.CustomerID AS Orders_CustomerID
FROM Customers
	LEFT JOIN Orders
		ON Customers.CustomerID = Orders.CustomerID
WHERE Orders.CustomerID IS NULL;


-- 31. Customers with no orders for EmployeeID 4
SELECT Customers.CustomerID AS Customers_CustomerID,
	Orders.CustomerID AS Orders_CustomerID
FROM Customers
	LEFT JOIN Orders
		ON Customers.CustomerID = Orders.CustomerID
		AND EmployeeID = 4
WHERE Orders.CustomerID IS NULL;


-- 32. High-value customers (values of individual order of 1 customer >= 10000)
SELECT Customers.CustomerID,
	Customers.CompanyName,
	Orders.OrderID,
	SUM(UnitPrice * Quantity) AS TotalOrderAmount
FROM Customers
	JOIN Orders
		ON Customers.CustomerID = Orders.CustomerID
	JOIN OrderDetails
		ON Orders.OrderID = OrderDetails.OrderID
WHERE YEAR(OrderDate) = 2016
GROUP BY Customers.CustomerID,
	Customers.CompanyName,
	Orders.OrderID
HAVING SUM(UnitPrice * Quantity) >= 10000
ORDER BY TotalOrderAmount DESC;


-- 33. High-value customers - total orders (values of total orders of 1 customer >= 15000, delete GROUP BY OrderID)
SELECT Customers.CustomerID,
	Customers.CompanyName,
	SUM(UnitPrice * Quantity) AS TotalOrderAmount
FROM Customers
	JOIN Orders
		ON Customers.CustomerID = Orders.CustomerID
	JOIN OrderDetails
		ON Orders.OrderID = OrderDetails.OrderID
WHERE YEAR(OrderDate) = 2016
GROUP BY Customers.CustomerID,
	Customers.CompanyName
HAVING SUM(UnitPrice * Quantity) >= 15000
ORDER BY TotalOrderAmount DESC;


-- 34. High-value customers - with discount
SELECT Customers.CustomerID,
	Customers.CompanyName,
	SUM(UnitPrice * Quantity) AS TotalsWithoutDiscount,
	SUM(UnitPrice * Quantity * (1 - Discount)) AS TotalsWithDiscount
FROM Customers
	JOIN Orders
		ON Customers.CustomerID = Orders.CustomerID
	JOIN OrderDetails
		ON Orders.OrderID = OrderDetails.OrderID
WHERE YEAR(OrderDate) = 2016
GROUP BY Customers.CustomerID,
	Customers.CompanyName
HAVING SUM(UnitPrice * Quantity * (1 - Discount)) >= 10000
ORDER BY TotalsWithDiscount DESC;


-- 35. Month-end orders
SELECT EmployeeID,	
	OrderID,
	OrderDate
FROM Orders
WHERE OrderDate = DATEADD(MONTH, 1 + DATEDIFF(MONTH, 0, OrderDate), -1)
ORDER BY EmployeeID, OrderID;


-- 36. Orders with many line items
SELECT TOP(10) OrderID,
	COUNT(*) AS TotalOrderDetails
FROM OrderDetails
GROUP BY OrderID
ORDER BY TotalOrderDetails DESC;


-- 37. Orders - random assortment
Select TOP (2) PERCENT OrderID
FROM Orders
ORDER BY NEWID();


-- 38. Orders - accidental double-entry
SELECT OrderID
FROM OrderDetails
WHERE Quantity >= 60
GROUP BY OrderID, Quantity
HAVING COUNT(Quantity) > 1;


-- 39. Orders - accidental double-entry details
SELECT *
FROM OrderDetails
WHERE OrderID IN (
	SELECT OrderID
	FROM OrderDetails
	WHERE Quantity >= 60
	GROUP BY OrderID, Quantity
	HAVING COUNT(Quantity) > 1)
ORDER BY OrderID, Quantity;


-- 40. Orders - accidental double-entry details, derived table
SELECT DISTINCT
	OrderDetails.OrderID
	,ProductID
	,UnitPrice
	,Quantity
	,Discount
FROM OrderDetails
	JOIN(
		SELECT OrderID
		FROM OrderDetails
		WHERE Quantity >= 60
		GROUP BY OrderID, Quantity
		HAVING Count(*) > 1
		) PotentialProblemOrders
	ON PotentialProblemOrders.OrderID = OrderDetails.OrderID
ORDER BY OrderID, ProductID;


-- 41. Late orders
SELECT OrderID,
	CONVERT(DATE, OrderDate) AS OrderDate,
	CONVERT(DATE, RequiredDate) AS RequiredDate,
	CONVERT(DATE, ShippedDate) AS ShippedDate
FROM Orders
WHERE RequiredDate <= ShippedDate;


-- 42. Late orders - which employees?
SELECT Employees.EmployeeID, 
	Employees.LastName,
	COUNT(*) AS TotalLateOrders
FROM Orders
	JOIN Employees
		ON Orders.EmployeeID = Employees.EmployeeID
WHERE RequiredDate <= ShippedDate
GROUP BY Employees.EmployeeID, Employees.LastName
ORDER BY TotalLateOrders DESC;


-- 43. Late orders vs. total orders
WITH a AS (
	SELECT EmployeeID,
		COUNT(*) AS LateOrders
	FROM Orders
	WHERE RequiredDate <= ShippedDate
	GROUP BY EmployeeID)
,b AS (
	SELECT EmployeeID,
		COUNT(*) AS AllOrders
	FROM Orders
	GROUP BY EmployeeID)
SELECT Employees.EmployeeID, 
	Employees.LastName,
	b.AllOrders,
	a.LateOrders
FROM Employees
	JOIN b
		ON Employees.EmployeeID = b.EmployeeID
	JOIN a
		ON Employees.EmployeeID = a.EmployeeID;


-- 44. Late orders vs. total orders - missing employee
WITH a AS (
	SELECT EmployeeID,
		COUNT(*) AS LateOrders
	FROM Orders
	WHERE RequiredDate <= ShippedDate
	GROUP BY EmployeeID)
,b AS (
	SELECT EmployeeID,
		COUNT(*) AS AllOrders
	FROM Orders
	GROUP BY EmployeeID)
SELECT Employees.EmployeeID, 
	Employees.LastName,
	b.AllOrders,
	a.LateOrders
FROM Employees
	JOIN b
		ON Employees.EmployeeID = b.EmployeeID
	LEFT JOIN a
		ON Employees.EmployeeID = a.EmployeeID;


-- 45. Late orders vs. total orders - fix null
WITH a AS (
	SELECT EmployeeID,
		COUNT(*) AS LateOrders
	FROM Orders
	WHERE RequiredDate <= ShippedDate
	GROUP BY EmployeeID)
,b AS (
	SELECT EmployeeID,
		COUNT(*) AS AllOrders
	FROM Orders
	GROUP BY EmployeeID)
SELECT Employees.EmployeeID, 
	Employees.LastName,
	b.AllOrders,
	ISNULL(a.LateOrders, 0) AS LateOrders
FROM Employees
	JOIN b
		ON Employees.EmployeeID = b.EmployeeID
	LEFT JOIN a
		ON Employees.EmployeeID = a.EmployeeID;


-- 46. Late orders vs. total orders - percentage
WITH a AS (
	SELECT EmployeeID,
		COUNT(*) AS LateOrders
	FROM Orders
	WHERE RequiredDate <= ShippedDate
	GROUP BY EmployeeID)
,b AS (
	SELECT EmployeeID,
		COUNT(*) AS AllOrders
	FROM Orders
	GROUP BY EmployeeID)
SELECT Employees.EmployeeID, 
	Employees.LastName,
	b.AllOrders,
	ISNULL(a.LateOrders, 0) AS LateOrders,
	(ISNULL(a.LateOrders, 0) * 1.00)/b.AllOrders AS PencentLateOrders
FROM Employees
	JOIN b
		ON Employees.EmployeeID = b.EmployeeID
	LEFT JOIN a
		ON Employees.EmployeeID = a.EmployeeID;


-- 47. Late orders vs. total orders - fix decimal
WITH a AS (
	SELECT EmployeeID,
		COUNT(*) AS LateOrders
	FROM Orders
	WHERE RequiredDate <= ShippedDate
	GROUP BY EmployeeID)
,b AS (
	SELECT EmployeeID,
		COUNT(*) AS AllOrders
	FROM Orders
	GROUP BY EmployeeID)
SELECT Employees.EmployeeID, 
	Employees.LastName,
	b.AllOrders,
	ISNULL(a.LateOrders, 0) AS LateOrders,
	CONVERT(DECIMAL(3,2),(ISNULL(a.LateOrders, 0) * 1.00)/b.AllOrders) AS PencentLateOrders
FROM Employees
	JOIN b
		ON Employees.EmployeeID = b.EmployeeID
	LEFT JOIN a
		ON Employees.EmployeeID = a.EmployeeID;


-- 48. Customer grouping
WITH Orders2016 AS(
	SELECT Customers.CustomerID,
		Customers.CompanyName,
		SUM(UnitPrice * Quantity) AS TotalOrderAmount
	FROM Customers
	JOIN Orders
		ON Customers.CustomerID = Orders.CustomerID
	JOIN OrderDetails
		ON Orders.OrderID = OrderDetails.OrderID
	WHERE YEAR(OrderDate) = 2016
	GROUP BY Customers.CustomerID,
		Customers.CompanyName)
SELECT CustomerID,
	CompanyName,
	TotalOrderAmount,
	CASE WHEN TotalOrderAmount BETWEEN 0 AND 1000 THEN 'Low'
		WHEN TotalOrderAmount BETWEEN 1000 AND 5000 THEN 'Medium'
		WHEN TotalOrderAmount BETWEEN 5000 AND 10000 THEN 'High'
		ELSE 'Very High' END AS CustomerGroup
FROM Orders2016
ORDER BY CustomerID;


-- 49. Customer grouping - fix null
WITH Orders2016 AS(
	SELECT Customers.CustomerID,
		Customers.CompanyName,
		SUM(UnitPrice * Quantity) AS TotalOrderAmount
	FROM Customers
	JOIN Orders
		ON Customers.CustomerID = Orders.CustomerID
	JOIN OrderDetails
		ON Orders.OrderID = OrderDetails.OrderID
	WHERE YEAR(OrderDate) = 2016
	GROUP BY Customers.CustomerID,
		Customers.CompanyName)
SELECT CustomerID,
	CompanyName,
	TotalOrderAmount,
	CASE WHEN TotalOrderAmount >= 0 AND TotalOrderAmount < 1000 THEN 'Low'
		WHEN TotalOrderAmount >= 1000 AND TotalOrderAmount < 5000 THEN 'Medium'
		WHEN TotalOrderAmount >= 5000 AND TotalOrderAmount < 10000 THEN 'High'
		ELSE 'Very High' END AS CustomerGroup
FROM Orders2016
ORDER BY CustomerID;


-- 50. Customer grouping with percentage
WITH Orders2016 AS(
	SELECT Customers.CustomerID,
		Customers.CompanyName,
		SUM(UnitPrice * Quantity) AS TotalOrderAmount
	FROM Customers
	JOIN Orders
		ON Customers.CustomerID = Orders.CustomerID
	JOIN OrderDetails
		ON Orders.OrderID = OrderDetails.OrderID
	WHERE YEAR(OrderDate) = 2016
	GROUP BY Customers.CustomerID,
		Customers.CompanyName)
,CustomerGroupTable AS(
	SELECT CustomerID,
		CompanyName,
		TotalOrderAmount,
		CASE WHEN TotalOrderAmount >= 0 AND TotalOrderAmount < 1000 THEN 'Low'
			WHEN TotalOrderAmount >= 1000 AND TotalOrderAmount < 5000 THEN 'Medium'
			WHEN TotalOrderAmount >= 5000 AND TotalOrderAmount < 10000 THEN 'High'
			ELSE 'Very High' END AS CustomerGroup
	FROM Orders2016)
SELECT CustomerGroup,
	COUNT(*) AS TotalInGroup,
	COUNT(*) * 1.00 / (SELECT COUNT(*) FROM CustomerGroupTable) AS PercentageInGroup
FROM CustomerGroupTable
GROUP BY CustomerGroup
ORDER BY PercentageInGroup DESC;


-- 51. Customer grouping - flexible
WITH Orders2016 AS(
	SELECT Customers.CustomerID,
		Customers.CompanyName,
		SUM(UnitPrice * Quantity) AS TotalOrderAmount
	FROM Customers
	JOIN Orders
		ON Customers.CustomerID = Orders.CustomerID
	JOIN OrderDetails
		ON Orders.OrderID = OrderDetails.OrderID
	WHERE YEAR(OrderDate) = 2016
	GROUP BY Customers.CustomerID,
		Customers.CompanyName)
SELECT CustomerID,
	CompanyName,
	TotalOrderAmount,
	CustomerGroupName
FROM Orders2016
	JOIN CustomerGroupThresholds
		ON Orders2016.TotalOrderAmount BETWEEN CustomerGroupThresholds.RangeBottom AND CustomerGroupThresholds.RangeTop
ORDER BY CustomerID;


-- 52. Countries with suppliers or customers
SELECT Country
FROM Suppliers
UNION
SELECT Country
FROM Customers
ORDER BY Country;


-- 53. Countries with suppliers or customers, version 2
WITH SupplierCountries AS(
	SELECT DISTINCT Country FROM Suppliers)
,CustomerCountries AS(
	SELECT DISTINCT Country FROM Customers)
SELECT SupplierCountries.Country AS SupplierCountry,
	CustomerCountries.Country AS CustomerCountry
FROM SupplierCountries
	FULL OUTER JOIN CustomerCountries
		ON SupplierCountries.Country = CustomerCountries.Country;

-- 54. Countries with suppliers or customers - version 3
WITH CountryTable AS(
	SELECT Country
	FROM Suppliers
	UNION
	SELECT Country
	FROM Customers)
, Sup AS(
	SELECT Country,
		COUNT(*) AS TotalSuppliers
	FROM Suppliers
	GROUP BY Country)
, Cus AS(
	SELECT Country,
		COUNT(*) AS TotalCustomers
	FROM Customers
	GROUP BY Country)
SELECT CountryTable.Country,
	ISNULL(TotalSuppliers,0) AS TotalSuppliers,
	ISNULL(TotalCustomers,0) AS TotalCustomers
FROM CountryTable
	LEFT JOIN Sup
		ON CountryTable.Country = Sup.Country
	LEFT JOIN Cus
		ON CountryTable.Country = Cus.Country;


-- 55. First order in each country
WITH a AS(
	SELECT ShipCountry,
		CustomerID,
		OrderID,
		CONVERT(Date, OrderDate) AS OrderDate,
		ROW_NUMBER() OVER (PARTITION BY ShipCountry ORDER BY ShipCountry, OrderID) AS RowNumber
	FROM Orders)
SELECT ShipCountry,
	CustomerID,
	OrderID,
	OrderDate
FROM a
WHERE RowNumber = 1;


-- 56. Customers with multiple orders in 5 day period (self join)
SELECT InitialOrder.CustomerID
	,InitialOrderID = InitialOrder.OrderID
	,InitialOrderDate = CONVERT(DATE,InitialOrder.OrderDate)
	,NextOrderID = NextOrder.OrderID
	,NextOrderDate = CONVERT(DATE,NextOrder.OrderDate)
	,DaysBetween = DATEDIFF(DAY,InitialOrder.OrderDate,NextOrder.OrderDate)
FROM Orders AS InitialOrder
	JOIN Orders AS NextOrder
		ON InitialOrder.CustomerID = NextOrder.CustomerID
WHERE InitialOrder.OrderID < NextOrder.OrderID
AND DATEDIFF(DAY,InitialOrder.OrderDate,NextOrder.OrderDate) <=5
ORDER BY InitialOrder.CustomerID
	,InitialOrder.OrderID;

	
-- 57. Customers with multiple orders in 5 day period, version 2
WITH a AS (
	SELECT CustomerID,
		OrderDate = CONVERT(Date,OrderDate),
		NextOrderDate = CONVERT(Date, LEAD(OrderDate, 1) OVER(PARTITION BY CustomerID ORDER BY CustomerID, OrderDate))
	FROM Orders)
SELECT *,
	DaysBetween = DATEDIFF(DAY,OrderDate,NextOrderDate)
FROM a
WHERE DATEDIFF(DAY,OrderDate,NextOrderDate) <=5
ORDER BY CustomerID
	,OrderDate;