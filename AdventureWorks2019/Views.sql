use AdventureWorks2019

-----Creacion de vista que muestra el listado de los productos descontinuados-----
IF OBJECT_ID (N'Discontinued_products') IS NOT NULL
   DROP VIEW Discontinued_products
GO

CREATE VIEW Discontinued_products
AS
	SELECT dp.ProductId, dp.[Name] as Productos_Descontinuados
	FROM Production.Product dp
	WHERE DiscontinuedDate IS NOT NULL
GO

SELECT * FROM Discontinued_products
GO


-----Creacion de vista que muestra un listado de productos activos, sus categorías, subcategorías y modelo-----
IF OBJECT_ID (N'Active_products') IS NOT NULL
   DROP VIEW Active_products
GO

CREATE VIEW Active_products
AS
	SELECT ap.ProductId, ap.[Name] as 'Productos Activos',  c.ProductCategoryID ,  sc.[Name] as 'SubCategoria'
	,PM.[Name] as 'Modelo'

	FROM Production.Product ap
	LEFT JOIN Production.ProductSubcategory sc ON ap.ProductSubcategoryID = sc.ProductSubcategoryID
	LEFT JOIN Production.ProductCategory c ON sc.ProductCategoryID = c.ProductCategoryID
	LEFT JOIN Production.ProductModel pm ON ap.ProductModelID = pm.ProductModelID
	WHERE (DiscontinuedDate IS NULL) AND (ap.ProductSubcategoryID IS NULL OR ap.ProductSubcategoryID IS NOT NULL)

	GROUP BY ap.ProductId, ap.[Name],  c.ProductCategoryID, sc.[Name], PM.[Name]
GO

SELECT * FROM Active_products
GO

-----Consulta que obtiene los datos generales de los empleados del departamento ‘Document Control’.----

SELECT hre.*, hrd.[Name] as 'Departamento', hrd.ModifiedDate 
FROM HumanResources.Employee hre
	INNER JOIN HumanResources.EmployeeDepartmentHistory edh ON hre.BusinessEntityID = edh.BusinessEntityID
	INNER JOIN HumanResources.Department hrd ON edh.DepartmentID = hrd.DepartmentID
	WHERE ([Name] = 'Document Control')