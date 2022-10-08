
--Crea un procedimiento almacenado que obtenga los datos generales de los empleados por departamento.
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'HumanResources'
     AND SPECIFIC_NAME = N'usp_FindByDepartment' 
)
   DROP PROCEDURE HumanResources.usp_FindByDepartment
GO

CREATE PROCEDURE HumanResources.usp_FindByDepartment
@DepartmentID SMALLINT =NULL
AS
	SELECT  hre.BusinessEntityID, p.FirstName + ' ' + p.MiddleName + ' ' + p.LastName as 'Nombre Completo', hrd.[Name] as 'Departamento'
	, hre.NationalIDNumber, hre.LoginID, hre.JobTitle, hre.BirthDate, hre.MaritalStatus, hre.Gender, hre.VacationHours, hre.SickLeaveHours
	
	FROM HumanResources.Employee hre
	INNER JOIN Person.Person p ON hre.BusinessEntityID = p.BusinessEntityID
	INNER JOIN HumanResources.EmployeeDepartmentHistory edh ON hre.BusinessEntityID = edh.BusinessEntityID
	INNER JOIN HumanResources.Department hrd ON edh.DepartmentID = hrd.DepartmentID
	WHERE (@DepartmentID IS NULL OR hrd.DepartmentID = @DepartmentID)
GO

EXEC HumanResources.usp_FindByDepartment 12
GO


--Crea un procedimiento que obtenga lista de cumpleañeros del mes ordenados alfabéticamente por el primer apellido 
--y por el nombre del departamento, si no se especifica DepartmentID entonces deberá retornar todos los datos
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'HumanResources'
     AND SPECIFIC_NAME = N'usp_BirthDateList' 
)
   DROP PROCEDURE HumanResources.usp_BirthDateList
GO

CREATE PROCEDURE HumanResources.usp_BirthDateList
AS
	SELECT hre.BusinessEntityID, p.FirstName + ' ' + p.MiddleName as 'Nombres', p.LastName as 'Apellido', hre.BirthDate
	, hrd.[Name] as 'Departamento', hre.JobTitle, hrd.DepartmentID
	FROM HumanResources.Employee hre
	INNER JOIN Person.Person p ON hre.BusinessEntityID = p.BusinessEntityID
	INNER JOIN HumanResources.EmployeeDepartmentHistory edh ON hre.BusinessEntityID = edh.BusinessEntityID
	INNER JOIN HumanResources.Department hrd ON edh.DepartmentID = hrd.DepartmentID
	WHERE MONTH(hre.BirthDate) = MONTH(GETDATE())
	ORDER BY P.LastName, hrd.DepartmentID
GO

EXEC HumanResources.usp_BirthDateList
GO


--Crea un procedimiento que obtenga la cantidad de empleados por departamento ordenados por nombre de departamento,
--si no se especifica DepartmentID entonces deberá retornar todos los datos.
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'HumanResources'
     AND SPECIFIC_NAME = N'usp_NumberEployeesPerDeparment' 
)
   DROP PROCEDURE HumanResources.usp_NumberEployeesPerDeparment
GO

CREATE PROCEDURE HumanResources.usp_NumberEployeesPerDeparment
@DeparmentID smallint = NULL
AS
	IF(@DeparmentID IS NOT NULL)
		SELECT hrd.DepartmentID, hrd.[Name] as 'Departamento', COUNT(hre.BusinessEntityID) as 'Numero de empleados'
		FROM HumanResources.Employee hre
		INNER JOIN Person.Person p ON hre.BusinessEntityID = p.BusinessEntityID
		INNER JOIN HumanResources.EmployeeDepartmentHistory edh ON hre.BusinessEntityID = edh.BusinessEntityID
		INNER JOIN HumanResources.Department hrd ON edh.DepartmentID = hrd.DepartmentID
		WHERE (hrd.DepartmentID = @DeparmentID)
		GROUP BY hrd.DepartmentID, hrd.[Name]
		
	ELSE
		SELECT hrd.DepartmentID, p.FirstName + ' ' + p.MiddleName as 'Nombres', p.LastName as 'Apellido', hrd.[Name] as 'Departamento'
		, hre.BirthDate, hre.JobTitle
		FROM HumanResources.Employee hre
		LEFT JOIN Person.Person p ON hre.BusinessEntityID = p.BusinessEntityID
		LEFT JOIN HumanResources.EmployeeDepartmentHistory edh ON hre.BusinessEntityID = edh.BusinessEntityID
		LEFT JOIN HumanResources.Department hrd ON edh.DepartmentID = hrd.DepartmentID	
GO

EXEC HumanResources.usp_NumberEployeesPerDeparment 12
GO


--Cree un procedimiento que retorne el Id del producto, nombre del producto, cantidad total de ventas (Sales.SalesOrderDetail)
--, monto total de ventas en un rango de fechas (Sales.SalesOrderHeader). El procedimiento debe tener los parámetros 
--@StartDate, @EndDate y 2 parámetros de retorno, los parámetros pueden ser nulos, si no especifican las fechas deberá retornar 
--los datos correspondientes al mes actual. El procedimiento debe validar que el rango de fechas sea válido, si el rango es inválido 
--deberá indicarse en los parámetros de retorno.
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'Production'
     AND SPECIFIC_NAME = N'usp_SalesByDateRange' 
)
   DROP PROCEDURE Production.usp_SalesByDateRange
GO

CREATE PROCEDURE Production.usp_SalesByDateRange
@StartDate date = NULL,
@EndDate date = NULL,
@Message VARCHAR(500) = NULL OUTPUT,
@Message2 VARCHAR(500) = NULL OUTPUT
AS
	
	IF(@StartDate IS NULL AND @EndDate IS NULL)
		SELECT pp.ProductID, pp.[Name] as 'Nombre del producto', soh.OrderDate, COUNT(sod.ProductID) as 'Cantidad Total de Ventas'
		, SUM(soh.TotalDue) as 'Monto de Ventas Totales'
		FROM Production.Product pp
		INNER JOIN Sales.SalesOrderDetail sod ON pp.ProductID = sod.ProductID
		INNER JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID

		--Este WHERE hace que se busquen las ventas del mes de la fecha actual.
		--WHERE soh.OrderDate BETWEEN DATEADD(DAY,1,EOMONTH(GETDATE(),-1)) AND EOMONTH(GETDATE())

		--Este WHERE hace que se busquen las ventas que tengan solamente el mismo mes, sin importar el año.
		WHERE  MONTH(soh.OrderDate) = MONTH(GETDATE())
			
		GROUP BY pp.ProductID,pp.[Name], sod.ProductID, soh.OrderDate 
			IF(@StartDate IS NULL AND @EndDate IS NULL)
			SET @Message = 'El rango de fechas no se ingresó, se usara el mes actual como rango';
	ELSE
		IF(@StartDate > '2011-01-01' AND @EndDate <= EOMONTH(GETDATE()))
			SELECT pp.ProductID, pp.[Name] as 'Nombre del producto', soh.OrderDate, COUNT(sod.ProductID) as 'Cantidad Total de Ventas'
			, SUM(soh.TotalDue) as 'Monto de Ventas Totales'
			FROM Production.Product pp
			INNER JOIN Sales.SalesOrderDetail sod ON pp.ProductID = sod.ProductID
			INNER JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
			WHERE CONVERT(date, soh.OrderDate) BETWEEN @StartDate AND @EndDate
			GROUP BY pp.ProductID, pp.[Name], sod.ProductID, soh.OrderDate 
		ELSE
			SET @Message2 = 'El rango de fechas no es válido';
GO

EXEC Production.usp_SalesByDateRange '2000-10-10','2011-10-10'
GO