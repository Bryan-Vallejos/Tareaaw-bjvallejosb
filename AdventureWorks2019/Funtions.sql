--Cree una función que obtenga el Id del producto, nombre del producto, cantidad total de ventas, monto total de ventas.
--La función debe tener dos parámetros @StartDate y @EndDate, los parámetros pueden ser nulos, si no especifican las fechas deberá retornar 
--los datos correspondientes al mes actual.

IF OBJECT_ID (N'Production.ufn_SalesByDateRange') IS NOT NULL
   DROP FUNCTION Production.ufn_SalesByDateRange
GO

CREATE FUNCTION Production.ufn_SalesByDateRange(@StartDate date = NULL,@EndDate date = NULL)
RETURNS @SalesByDateRange TABLE (
		ProductID INT,
		ProductName NVARCHAR(50),
		OrderDate datetime,
		SalesTotal DECIMAL(18,2),
		SalesTotalAmount DECIMAL(18,2)
	)
AS
BEGIN
	IF(@StartDate IS NULL AND @EndDate IS NULL)

		INSERT INTO @SalesByDateRange(ProductID, ProductName, OrderDate, SalesTotal, SalesTotalAmount)
		SELECT pp.ProductID, pp.[Name] , soh.OrderDate, COUNT(sod.ProductID) 
		, SUM(soh.TotalDue) 
		FROM Production.Product pp
		INNER JOIN Sales.SalesOrderDetail sod ON pp.ProductID = sod.ProductID
		INNER JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
		WHERE  MONTH(soh.OrderDate) = MONTH(GETDATE())
		GROUP BY pp.ProductID,pp.[Name], sod.ProductID, soh.OrderDate
	ELSE
		INSERT INTO @SalesByDateRange(ProductID, ProductName, OrderDate, SalesTotal, SalesTotalAmount)
		SELECT pp.ProductID, pp.[Name] , soh.OrderDate, COUNT(sod.ProductID)
		, SUM(soh.TotalDue) 
		FROM Production.Product pp
		INNER JOIN Sales.SalesOrderDetail sod ON pp.ProductID = sod.ProductID
		INNER JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
		WHERE CONVERT(date, soh.OrderDate) BETWEEN @StartDate AND @EndDate
		GROUP BY pp.ProductID, pp.[Name], sod.ProductID, soh.OrderDate
	RETURN;
END
GO

SELECT * FROM Production.ufn_SalesByDateRange('2011-10-10','2012-10-10')
go
 
--Cree una función que obtenga retorne el Id del producto, nombre del producto, cantidad total de ventas, monto total de ventas de un año. 
--La función debe tener un parámetro @year, si no se especifica el año deberá retornar los datos correspondientes al año actual.
IF OBJECT_ID (N'Production.ufn_SalesByYear') IS NOT NULL
   DROP FUNCTION Production.ufn_SalesByYear
GO

CREATE FUNCTION Production.ufn_SalesByYear(@Year INT= null)
RETURNS @SalesByYear TABLE (
		ProductID INT,
		ProductName NVARCHAR(50),
		OrderDate datetime,
		SalesTotal DECIMAL(18,2),
		SalesTotalAmount DECIMAL(18,2)
	)
AS
BEGIN
	IF(@Year IS NULL)
	
		INSERT INTO @SalesByYear(ProductID, ProductName, OrderDate, SalesTotal, SalesTotalAmount)
		SELECT pp.ProductID, pp.[Name] , soh.OrderDate, COUNT(sod.ProductID) 
		, SUM(soh.TotalDue) 
		FROM Production.Product pp
		INNER JOIN Sales.SalesOrderDetail sod ON pp.ProductID = sod.ProductID
		INNER JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
		WHERE  YEAR(soh.OrderDate) = YEAR(GETDATE())
		GROUP BY pp.ProductID,pp.[Name], sod.ProductID, soh.OrderDate
	ELSE
		INSERT INTO @SalesByYear(ProductID, ProductName, OrderDate, SalesTotal, SalesTotalAmount)
		SELECT pp.ProductID, pp.[Name] , soh.OrderDate, COUNT(sod.ProductID)
		, SUM(soh.TotalDue) 
		FROM Production.Product pp
		INNER JOIN Sales.SalesOrderDetail sod ON pp.ProductID = sod.ProductID
		INNER JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
		WHERE YEAR(soh.OrderDate) = @Year
		GROUP BY pp.ProductID, pp.[Name], sod.ProductID, soh.OrderDate
	RETURN;
END
GO

SELECT * FROM Production.ufn_SalesByYear(2012)
go

--Cree una función que obtenga retorne el Id del producto, nombre del producto, cantidad total de ventas, monto total de ventas por mes en un año
--, cada mes deberá ser una columna. La función debe tener un parámetro @year, si no se especifica el año deberá retornar los datos 
--correspondientes al año actual.
IF OBJECT_ID (N'Production.ufn_SalesByMonth') IS NOT NULL
   DROP FUNCTION Production.ufn_SalesByMonth
GO

CREATE FUNCTION Production.ufn_SalesByMonth(@Year INT= null)
RETURNS @SalesByMonth TABLE (
		ProductID INT,
		ProductName NVARCHAR(50),
		OrderDate datetime,
		SalesTotal DECIMAL(18,2),
		Enero DECIMAL(18,2),Febrero DECIMAL(18,2),Marzo DECIMAL(18,2),Abril DECIMAL(18,2),Mayo DECIMAL(18,2)
		,Junio DECIMAL(18,2),Julio DECIMAL(18,2),Agosto DECIMAL(18,2),Septiembre DECIMAL(18,2),Octubre DECIMAL(18,2)
		,Noviembre DECIMAL(18,2),Diciembre DECIMAL(18,2)
	)
AS
BEGIN
	IF(@Year IS NULL)
	
		INSERT INTO @SalesByMonth(ProductID, ProductName, OrderDate, SalesTotal, Enero ,Febrero ,Marzo ,Abril ,Mayo
		,Junio ,Julio ,Agosto ,Septiembre ,Octubre ,Noviembre ,Diciembre )
		SELECT pp.ProductID, pp.[Name] , soh.OrderDate, COUNT(sod.ProductID) 
		, SUM(soh.TotalDue) as Enero, SUM(soh.TotalDue) as Febrero, SUM(soh.TotalDue) as Marzo, SUM(soh.TotalDue) as Abril, SUM(soh.TotalDue) as Mayo
		,SUM(soh.TotalDue) as Junio, SUM(soh.TotalDue) as Julio, SUM(soh.TotalDue) as Agosto, SUM(soh.TotalDue) as Septiembre, SUM(soh.TotalDue) as Octubre
		,SUM(soh.TotalDue) as Noviembre, SUM(soh.TotalDue) as Diciembre
		FROM Production.Product pp
		INNER JOIN Sales.SalesOrderDetail sod ON pp.ProductID = sod.ProductID
		INNER JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
		WHERE  YEAR(soh.OrderDate) = YEAR(GETDATE())
		GROUP BY pp.ProductID,pp.[Name], sod.ProductID, soh.OrderDate
	ELSE
		INSERT INTO @SalesByMonth(ProductID, ProductName, OrderDate, SalesTotal, Enero ,Febrero ,Marzo ,Abril ,Mayo
		,Junio ,Julio ,Agosto ,Septiembre ,Octubre ,Noviembre ,Diciembre)
		SELECT pp.ProductID, pp.[Name] as 'Nombre del producto', soh.OrderDate, COUNT(sod.ProductID) as 'Cantidad Total de Ventas'
		, SUM(soh.TotalDue) as Enero, SUM(soh.TotalDue) as Febrero, SUM(soh.TotalDue) as Marzo, SUM(soh.TotalDue) as Abril, SUM(soh.TotalDue) as Mayo
		,SUM(soh.TotalDue) as Junio, SUM(soh.TotalDue) as Julio, SUM(soh.TotalDue) as Agosto, SUM(soh.TotalDue) as Septiembre, SUM(soh.TotalDue) as Octubre
		,SUM(soh.TotalDue) as Noviembre, SUM(soh.TotalDue) as Diciembre
		FROM Production.Product pp
		INNER JOIN Sales.SalesOrderDetail sod ON pp.ProductID = sod.ProductID
		INNER JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
		WHERE YEAR(soh.OrderDate) = @Year AND MONTH(soh.OrderDate) = MONTH(GETDATE())
		GROUP BY pp.ProductID, pp.[Name], sod.ProductID, soh.OrderDate
	RETURN;
END
GO

SELECT * FROM Production.ufn_SalesByMonth(2012)
go