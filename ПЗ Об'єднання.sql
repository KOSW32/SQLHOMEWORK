
CREATE TABLE Departments (
Id INT IDENTITY PRIMARY KEY,
Building INT NOT NULL CHECK(Building BETWEEN 1 AND 5),
Financing MONEY NOT NULL DEFAULT 0 CHECK(Financing >= 0),
Name NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Diseases (
Id INT IDENTITY PRIMARY KEY,
Name NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Doctors (
Id INT IDENTITY PRIMARY KEY,
Name NVARCHAR(MAX) NOT NULL,
Surname NVARCHAR(MAX) NOT NULL,
Salary MONEY NOT NULL CHECK(Salary > 0)
);

CREATE TABLE Examinations (
Id INT IDENTITY PRIMARY KEY,
Name NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Wards (
Id INT IDENTITY PRIMARY KEY,
Name NVARCHAR(20) NOT NULL UNIQUE,
Places INT NOT NULL CHECK(Places >= 1),
DepartmentId INT NOT NULL,
FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
);

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

CREATE TABLE Interns (
Id INT IDENTITY PRIMARY KEY,
DoctorId INT NOT NULL,
FOREIGN KEY (DoctorId) REFERENCES Doctors(Id)
);

CREATE TABLE Professors (
Id INT IDENTITY PRIMARY KEY,
DoctorId INT NOT NULL,
FOREIGN KEY (DoctorId) REFERENCES Doctors(Id)
);

INSERT INTO Departments (Building, Financing, Name) VALUES
(5,30000,'Ophthalmology'),
(5,25000,'Physiotherapy'),
(3,15000,'Cardiology');

INSERT INTO Wards (Name, Places, DepartmentId) VALUES
('A1',20,1),
('A2',6,1),
('B1',4,2),
('C1',3,3);

INSERT INTO Doctors (Name,Surname,Salary) VALUES
('John','Smith',5000),
('Mike','Brown',7000),
('Anna','White',3000);

INSERT INTO Interns (DoctorId) VALUES (3);
INSERT INTO Professors (DoctorId) VALUES (2);

INSERT INTO Diseases (Name) VALUES ('Flu'),('Cold'),('Cancer');

INSERT INTO Examinations (Name) VALUES ('XRay'),('MRI');

INSERT INTO DoctorsExaminations (DiseaseId,DoctorId,ExaminationId,WardId)
VALUES
(1,1,1,1),
(2,2,2,2);

SELECT Name, Places FROM Wards
WHERE DepartmentId IN (SELECT Id FROM Departments WHERE Building=5)
AND Places>=5
AND EXISTS (
SELECT 1 FROM Wards w
JOIN Departments d ON w.DepartmentId=d.Id
WHERE d.Building=5 AND w.Places>15
);

SELECT DISTINCT d.Name
FROM Departments d
JOIN Wards w ON w.DepartmentId=d.Id
JOIN DoctorsExaminations de ON de.WardId=w.Id
WHERE de.Date>=DATEADD(DAY,-7,GETDATE());

SELECT Name FROM Diseases
WHERE Id NOT IN (SELECT DiseaseId FROM DoctorsExaminations);

SELECT Name + ' ' + Surname FROM Doctors
WHERE Id NOT IN (SELECT DoctorId FROM DoctorsExaminations);

SELECT Name FROM Departments
WHERE Id NOT IN (
SELECT d.Id FROM Departments d
JOIN Wards w ON w.DepartmentId=d.Id
JOIN DoctorsExaminations de ON de.WardId=w.Id
);

SELECT Surname FROM Doctors
WHERE Id IN (SELECT DoctorId FROM Interns);

SELECT Surname FROM Doctors
WHERE Id IN (SELECT DoctorId FROM Interns)
AND Salary > ANY (SELECT Salary FROM Doctors);

SELECT Name FROM Wards
WHERE Places > ALL (
SELECT Places FROM Wards w
JOIN Departments d ON w.DepartmentId=d.Id
WHERE d.Building=3
);

SELECT DISTINCT d.Surname FROM Doctors d
JOIN DoctorsExaminations de ON d.Id=de.DoctorId
JOIN Wards w ON de.WardId=w.Id
JOIN Departments dep ON w.DepartmentId=dep.Id
WHERE dep.Name IN ('Ophthalmology','Physiotherapy');

SELECT Name FROM Departments
WHERE Id IN (
SELECT d.Id FROM Departments d
JOIN Wards w ON w.DepartmentId=d.Id
JOIN DoctorsExaminations de ON de.WardId=w.Id
WHERE de.DoctorId IN (SELECT DoctorId FROM Interns)
)
AND Id IN (
SELECT d.Id FROM Departments d
JOIN Wards w ON w.DepartmentId=d.Id
JOIN DoctorsExaminations de ON de.WardId=w.Id
WHERE de.DoctorId IN (SELECT DoctorId FROM Professors)
);

SELECT DISTINCT d.Name + ' ' + d.Surname, dep.Name
FROM Doctors d
JOIN DoctorsExaminations de ON d.Id=de.DoctorId
JOIN Wards w ON de.WardId=w.Id
JOIN Departments dep ON w.DepartmentId=dep.Id
WHERE dep.Financing>20000;

SELECT TOP 1 dep.Name
FROM Doctors d
JOIN DoctorsExaminations de ON d.Id=de.DoctorId
JOIN Wards w ON de.WardId=w.Id
JOIN Departments dep ON w.DepartmentId=dep.Id
ORDER BY d.Salary DESC;

SELECT dis.Name, COUNT(de.Id)
FROM Diseases dis
LEFT JOIN DoctorsExaminations de ON dis.Id=de.DiseaseId
GROUP BY dis.Name;
