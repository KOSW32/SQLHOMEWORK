CREATE DATABASE Hospital;
GO

USE Hospital;
GO

-- Departments
CREATE TABLE Departments (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE
);

-- Doctors
CREATE TABLE Doctors (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(MAX) NOT NULL,
    Surname NVARCHAR(MAX) NOT NULL,
    Salary MONEY NOT NULL CHECK (Salary > 0),
    Premium MONEY NOT NULL DEFAULT 0 CHECK (Premium >= 0)
);

-- Specializations
CREATE TABLE Specializations (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE
);

-- DoctorsSpecializations
CREATE TABLE DoctorsSpecializations (
    Id INT IDENTITY PRIMARY KEY,
    DoctorId INT NOT NULL,
    SpecializationId INT NOT NULL,
    FOREIGN KEY (DoctorId) REFERENCES Doctors(Id),
    FOREIGN KEY (SpecializationId) REFERENCES Specializations(Id)
);

-- Sponsors
CREATE TABLE Sponsors (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE
);

-- Donations
CREATE TABLE Donations (
    Id INT IDENTITY PRIMARY KEY,
    Amount MONEY NOT NULL CHECK (Amount > 0),
    Date DATE NOT NULL DEFAULT GETDATE(),
    DepartmentId INT NOT NULL,
    SponsorId INT NOT NULL,
    FOREIGN KEY (DepartmentId) REFERENCES Departments(Id),
    FOREIGN KEY (SponsorId) REFERENCES Sponsors(Id)
);

-- Vacations
CREATE TABLE Vacations (
    Id INT IDENTITY PRIMARY KEY,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    DoctorId INT NOT NULL,
    FOREIGN KEY (DoctorId) REFERENCES Doctors(Id),
    CHECK (EndDate > StartDate)
);

-- Wards
CREATE TABLE Wards (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(20) NOT NULL UNIQUE,
    DepartmentId INT NOT NULL,
    FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
);

-- 1
SELECT d.Name + ' ' + d.Surname AS FullName, s.Name AS Specialization
FROM Doctors d
JOIN DoctorsSpecializations ds ON d.Id = ds.DoctorId
JOIN Specializations s ON s.Id = ds.SpecializationId;

-- 2
SELECT Surname, (Salary + Premium) AS TotalSalary
FROM Doctors
WHERE Id NOT IN (
    SELECT DoctorId FROM Vacations
    WHERE GETDATE() BETWEEN StartDate AND EndDate
);

-- 3
SELECT w.Name
FROM Wards w
JOIN Departments d ON w.DepartmentId = d.Id
WHERE d.Name = 'Intensive Treatment';

-- 4
SELECT DISTINCT d.Name
FROM Departments d
JOIN Donations don ON d.Id = don.DepartmentId
JOIN Sponsors s ON s.Id = don.SponsorId
WHERE s.Name = 'Umbrella Corporation';

-- 5
SELECT d.Name AS Department, s.Name AS Sponsor, don.Amount, don.Date
FROM Donations don
JOIN Departments d ON d.Id = don.DepartmentId
JOIN Sponsors s ON s.Id = don.SponsorId
WHERE don.Date >= DATEADD(MONTH, -1, GETDATE());

-- 6
SELECT DISTINCT d.Surname, dep.Name AS Department
FROM Doctors d
JOIN DoctorsSpecializations ds ON d.Id = ds.DoctorId
JOIN Departments dep ON dep.Id = ds.DoctorId
WHERE DATENAME(WEEKDAY, GETDATE()) NOT IN ('Saturday', 'Sunday');

-- 7
SELECT w.Name, d.Name AS Department
FROM Wards w
JOIN Departments d ON w.DepartmentId = d.Id
JOIN Doctors doc ON doc.Name = 'Helen' AND doc.Surname = 'Williams';

-- 8
SELECT DISTINCT d.Name, doc.Surname
FROM Departments d
JOIN Donations don ON d.Id = don.DepartmentId
JOIN Doctors doc ON doc.Id = d.Id
WHERE don.Amount > 100000;

-- 9
SELECT DISTINCT d.Name
FROM Departments d
JOIN Doctors doc ON doc.Id = d.Id
WHERE doc.Premium = 0;

-- 10
SELECT DISTINCT s.Name
FROM Specializations s
JOIN DoctorsSpecializations ds ON s.Id = ds.SpecializationId;

-- 11
SELECT DISTINCT d.Name, 'DiseaseName' AS Disease
FROM Departments d
JOIN Wards w ON w.DepartmentId = d.Id;

-- 12
SELECT DISTINCT d.Name, w.Name
FROM Departments d
JOIN Wards w ON w.DepartmentId = d.Id;

