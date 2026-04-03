CREATE DATABASE HospitalExams;
GO

USE HospitalExams;
GO


CREATE TABLE Departments (
    Id INT IDENTITY PRIMARY KEY,
    Building INT NOT NULL CHECK (Building BETWEEN 1 AND 5),
    Financing MONEY NOT NULL DEFAULT 0 CHECK (Financing >= 0),
    Name NVARCHAR(100) NOT NULL UNIQUE
);
GO


CREATE TABLE Diseases (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE
);
GO


CREATE TABLE Doctors (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(MAX) NOT NULL,
    Surname NVARCHAR(MAX) NOT NULL,
    Salary MONEY NOT NULL CHECK (Salary > 0)
);
GO


CREATE TABLE Examinations (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE
);
GO


CREATE TABLE Wards (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(20) NOT NULL UNIQUE,
    Places INT NOT NULL CHECK (Places >= 1),
    DepartmentId INT NOT NULL,
    FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
);
GO


CREATE TABLE DoctorsExaminations (
    Id INT IDENTITY PRIMARY KEY,
    Date DATE NOT NULL DEFAULT GETDATE(),
    DiseaseId INT NOT NULL,
    DoctorId INT NOT NULL,
    ExaminationId INT NOT NULL,
    WardId INT NOT NULL,
    FOREIGN KEY (DiseaseId) REFERENCES Diseases(Id),
    FOREIGN KEY (DoctorId) REFERENCES Doctors(Id),
    FOREIGN KEY (ExaminationId) REFERENCES Examinations(Id),
    FOREIGN KEY (WardId) REFERENCES Wards(Id)
);
GO


CREATE TABLE Interns (
    Id INT IDENTITY PRIMARY KEY,
    DoctorId INT NOT NULL,
    FOREIGN KEY (DoctorId) REFERENCES Doctors(Id)
);
GO

CREATE TABLE Professors (
    Id INT IDENTITY PRIMARY KEY,
    DoctorId INT NOT NULL,
    FOREIGN KEY (DoctorId) REFERENCES Doctors(Id)
);
GO


-- 1
SELECT w.Name, w.Places
FROM Wards w
JOIN Departments d ON w.DepartmentId = d.Id
WHERE d.Building = 5 AND w.Places >= 5
AND EXISTS (
    SELECT 1 FROM Wards w2
    JOIN Departments d2 ON w2.DepartmentId = d2.Id
    WHERE d2.Building = 5 AND w2.Places > 15
);

-- 2
SELECT DISTINCT d.Name
FROM Departments d
JOIN Wards w ON w.DepartmentId = d.Id
JOIN DoctorsExaminations de ON de.WardId = w.Id
WHERE de.Date >= DATEADD(WEEK, -1, GETDATE());

-- 3
SELECT Name
FROM Diseases
WHERE Id NOT IN (
    SELECT DISTINCT DiseaseId FROM DoctorsExaminations
);

-- 4
SELECT Name + ' ' + Surname
FROM Doctors
WHERE Id NOT IN (
    SELECT DISTINCT DoctorId FROM DoctorsExaminations
);

-- 5
SELECT Name
FROM Departments d
WHERE NOT EXISTS (
    SELECT 1
    FROM Wards w
    JOIN DoctorsExaminations de ON de.WardId = w.Id
    WHERE w.DepartmentId = d.Id
);

-- 6
SELECT d.Surname
FROM Doctors d
JOIN Interns i ON d.Id = i.DoctorId;

-- 7
SELECT d.Surname
FROM Doctors d
JOIN Interns i ON d.Id = i.DoctorId
WHERE d.Salary > ANY (
    SELECT Salary FROM Doctors
);

-- 8
SELECT Name
FROM Wards
WHERE Places > ALL (
    SELECT Places
    FROM Wards w
    JOIN Departments d ON w.DepartmentId = d.Id
    WHERE d.Building = 3
);

-- 9
SELECT DISTINCT d.Surname
FROM Doctors d
JOIN DoctorsExaminations de ON d.Id = de.DoctorId
JOIN Wards w ON w.Id = de.WardId
JOIN Departments dep ON dep.Id = w.DepartmentId
WHERE dep.Name IN ('Ophthalmology', 'Physiotherapy');

-- 10
SELECT d.Name
FROM Departments d
WHERE EXISTS (
    SELECT 1 FROM Wards w
    JOIN DoctorsExaminations de ON de.WardId = w.Id
    JOIN Interns i ON i.DoctorId = de.DoctorId
    WHERE w.DepartmentId = d.Id
)
AND EXISTS (
    SELECT 1 FROM Wards w
    JOIN DoctorsExaminations de ON de.WardId = w.Id
    JOIN Professors p ON p.DoctorId = de.DoctorId
    WHERE w.DepartmentId = d.Id
);

-- 11
SELECT doc.Name + ' ' + doc.Surname, d.Name
FROM Doctors doc
JOIN DoctorsExaminations de ON doc.Id = de.DoctorId
JOIN Wards w ON w.Id = de.WardId
JOIN Departments d ON d.Id = w.DepartmentId
WHERE d.Financing > 20000;

-- 12
SELECT TOP 1 d.Name
FROM Doctors doc
JOIN DoctorsExaminations de ON doc.Id = de.DoctorId
JOIN Wards w ON w.Id = de.WardId
JOIN Departments d ON d.Id = w.DepartmentId
ORDER BY doc.Salary DESC;

-- 13
SELECT dis.Name, COUNT(*) 
FROM Diseases dis
JOIN DoctorsExaminations de ON dis.Id = de.DiseaseId
GROUP BY dis.Name;
