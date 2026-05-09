USE master;

CREATE TABLE Products (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    ProductType NVARCHAR(100) NOT NULL,
    Quantity INT NOT NULL,
    CostPrice MONEY NOT NULL,
    Manufacturer NVARCHAR(100) NOT NULL,
    SalePrice MONEY NOT NULL
);

CREATE TABLE Employees (
    Id INT IDENTITY PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Position NVARCHAR(100) NOT NULL,
    HireDate DATE NOT NULL,
    Gender NVARCHAR(10) NOT NULL,
    Salary MONEY NOT NULL
);

CREATE TABLE Clients (
    Id INT IDENTITY PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(20) NOT NULL,
    Gender NVARCHAR(10) NOT NULL,
    DiscountPercent INT DEFAULT 0,
    MailingSubscription BIT NOT NULL
);

CREATE TABLE Sales (
    Id INT IDENTITY PRIMARY KEY,
    ProductId INT NOT NULL REFERENCES Products(Id),
    EmployeeId INT NOT NULL REFERENCES Employees(Id),
    ClientId INT NULL REFERENCES Clients(Id),
    Quantity INT NOT NULL,
    SalePrice MONEY NOT NULL,
    SaleDate DATE NOT NULL
);

CREATE TABLE History (
    Id INT IDENTITY PRIMARY KEY,
    ProductId INT,
    EmployeeId INT,
    ClientId INT,
    Quantity INT,
    SalePrice MONEY,
    SaleDate DATE
);

CREATE TABLE ArchiveProducts (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(100),
    ProductType NVARCHAR(100),
    Manufacturer NVARCHAR(100)
);

CREATE TABLE LastUnit (
    Id INT IDENTITY PRIMARY KEY,
    ProductName NVARCHAR(100),
    SaleDate DATE
);

CREATE TABLE EmployeesArchive (
    Id INT,
    FullName NVARCHAR(100),
    Position NVARCHAR(100),
    HireDate DATE,
    Gender NVARCHAR(10),
    Salary MONEY,
    FiredDate DATE
);

GO

CREATE TRIGGER trg_ProductsInsert
ON Products
INSTEAD OF INSERT
AS
BEGIN

    IF EXISTS (
        SELECT *
        FROM inserted
        WHERE Manufacturer = 'Спорт, сонце та штанга'
    )
    BEGIN
        RAISERROR('This manufacturer is forbidden',16,1)
        RETURN
    END

    IF EXISTS (
        SELECT *
        FROM Products p
        JOIN inserted i
        ON p.Name = i.Name
        AND p.ProductType = i.ProductType
        AND p.CostPrice = i.CostPrice
        AND p.Manufacturer = i.Manufacturer
        AND p.SalePrice = i.SalePrice
    )
    BEGIN
        UPDATE p
        SET p.Quantity = p.Quantity + i.Quantity
        FROM Products p
        JOIN inserted i
        ON p.Name = i.Name
        AND p.ProductType = i.ProductType
        AND p.CostPrice = i.CostPrice
        AND p.Manufacturer = i.Manufacturer
        AND p.SalePrice = i.SalePrice
    END
    ELSE
    BEGIN
        INSERT INTO Products
        (
            Name,
            ProductType,
            Quantity,
            CostPrice,
            Manufacturer,
            SalePrice
        )
        SELECT
            Name,
            ProductType,
            Quantity,
            CostPrice,
            Manufacturer,
            SalePrice
        FROM inserted
    END

END;

GO

CREATE TRIGGER trg_InsertHistory
ON Sales
AFTER INSERT
AS
BEGIN

    INSERT INTO History
    (
        ProductId,
        EmployeeId,
        ClientId,
        Quantity,
        SalePrice,
        SaleDate
    )
    SELECT
        ProductId,
        EmployeeId,
        ClientId,
        Quantity,
        SalePrice,
        SaleDate
    FROM inserted

END;

GO

CREATE TRIGGER trg_MoveToArchive
ON Sales
AFTER INSERT
AS
BEGIN

    UPDATE p
    SET p.Quantity = p.Quantity - i.Quantity
    FROM Products p
    JOIN inserted i
    ON p.Id = i.ProductId

    INSERT INTO ArchiveProducts
    (
        Name,
        ProductType,
        Manufacturer
    )
    SELECT
        p.Name,
        p.ProductType,
        p.Manufacturer
    FROM Products p
    JOIN inserted i
    ON p.Id = i.ProductId
    WHERE p.Quantity = 0

END;

GO

CREATE TRIGGER trg_CheckDuplicateClient
ON Clients
INSTEAD OF INSERT
AS
BEGIN

    IF EXISTS (
        SELECT *
        FROM Clients c
        JOIN inserted i
        ON c.FullName = i.FullName
        AND c.Email = i.Email
    )
    BEGIN
        RAISERROR('Client already exists',16,1)
    END
    ELSE
    BEGIN
        INSERT INTO Clients
        (
            FullName,
            Email,
            Phone,
            Gender,
            DiscountPercent,
            MailingSubscription
        )
        SELECT
            FullName,
            Email,
            Phone,
            Gender,
            DiscountPercent,
            MailingSubscription
        FROM inserted
    END

END;

GO

CREATE TRIGGER trg_PreventClientDelete
ON Clients
INSTEAD OF DELETE
AS
BEGIN
    RAISERROR('Deleting clients is forbidden',16,1)
END;

GO

CREATE TRIGGER trg_PreventOldEmployeeDelete
ON Employees
INSTEAD OF DELETE
AS
BEGIN

    IF EXISTS (
        SELECT *
        FROM deleted
        WHERE YEAR(HireDate) < 2015
    )
    BEGIN
        RAISERROR('Cannot delete employees hired before 2015',16,1)
    END
    ELSE
    BEGIN

        INSERT INTO EmployeesArchive
        (
            Id,
            FullName,
            Position,
            HireDate,
            Gender,
            Salary,
            FiredDate
        )
        SELECT
            Id,
            FullName,
            Position,
            HireDate,
            Gender,
            Salary,
            GETDATE()
        FROM deleted

        DELETE FROM Employees
        WHERE Id IN (SELECT Id FROM deleted)

    END

END;

GO


/*1*/


CREATE TRIGGER trg_UpdateDiscount
ON Sales
AFTER INSERT
AS
BEGIN

    UPDATE Clients
    SET DiscountPercent = 15
    WHERE Id IN
    (
        SELECT ClientId
        FROM Sales
        GROUP BY ClientId
        HAVING SUM(Quantity * SalePrice) > 50000
    )

END;

GO

CREATE TRIGGER trg_LastUnit
ON Sales
AFTER INSERT
AS
BEGIN

    INSERT INTO LastUnit
    (
        ProductName,
        SaleDate
    )
    SELECT
        p.Name,
        GETDATE()
    FROM Products p
    JOIN inserted i
    ON p.Id = i.ProductId
    WHERE p.Quantity = 1

END;

GO

CREATE TRIGGER trg_LimitSellers
ON Employees
INSTEAD OF INSERT
AS
BEGIN

    IF (
        SELECT COUNT(*)
        FROM Employees
        WHERE Position = 'Seller'
    ) >= 5
    AND EXISTS (
        SELECT *
        FROM inserted
        WHERE Position = 'Seller'
    )
    BEGIN
        RAISERROR('Maximum number of sellers reached',16,1)
    END
    ELSE
    BEGIN

        INSERT INTO Employees
        (
            FullName,
            Position,
            HireDate,
            Gender,
            Salary
        )
        SELECT
            FullName,
            Position,
            HireDate,
            Gender,
            Salary
        FROM inserted

    END

END;

GO

INSERT INTO Products
(
    Name,
    ProductType,
    Quantity,
    CostPrice,
    Manufacturer,
    SalePrice
)
VALUES
('Nike Air','Shoes',10,2000,'Nike',3500),
('Adidas TShirt','Clothes',5,500,'Adidas',1000),
('Puma Shorts','Clothes',1,400,'Puma',900);

INSERT INTO Employees
(
    FullName,
    Position,
    HireDate,
    Gender,
    Salary
)
VALUES
('Ivan Petrov','Seller','2014-05-10','Male',20000),
('Anna Ivanova','Manager','2018-03-15','Female',30000);

INSERT INTO Clients
(
    FullName,
    Email,
    Phone,
    Gender,
    DiscountPercent,
    MailingSubscription
)
VALUES
('Oleg Sidorov','oleg@gmail.com','+380991112233','Male',0,1),
('Maria Bondar','maria@gmail.com','+380992223344','Female',5,0);

INSERT INTO Sales
(
    ProductId,
    EmployeeId,
    ClientId,
    Quantity,
    SalePrice,
    SaleDate
)
VALUES
(1,1,1,2,3500,GETDATE()),
(3,2,2,1,900,GETDATE());