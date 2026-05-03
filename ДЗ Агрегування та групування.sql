IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'UniversityDB')
BEGIN
    CREATE DATABASE UniversityDB
END

CREATE TABLE Faculties (
    Id INT PRIMARY KEY IDENTITY,
    Name NVARCHAR(100)
);

CREATE TABLE Departments (
    Id INT PRIMARY KEY IDENTITY,
    Name NVARCHAR(100),
    Financing FLOAT,
    FacultyId INT,
    FOREIGN KEY (FacultyId) REFERENCES Faculties(Id)
);

CREATE TABLE Teachers (
    Id INT PRIMARY KEY IDENTITY,
    Name NVARCHAR(100),
    Salary FLOAT,
    DepartmentId INT,
    FacultyId INT,
    FOREIGN KEY (DepartmentId) REFERENCES Departments(Id),
    FOREIGN KEY (FacultyId) REFERENCES Faculties(Id)
);

CREATE TABLE Students (
    Id INT PRIMARY KEY IDENTITY,
    Name NVARCHAR(100)
);

CREATE TABLE Disciplines (
    Id INT PRIMARY KEY IDENTITY,
    Name NVARCHAR(100),
    DepartmentId INT,
    FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
);

CREATE TABLE TeacherDisciplines (
    TeacherId INT,
    DisciplineId INT,
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id),
    FOREIGN KEY (DisciplineId) REFERENCES Disciplines(Id)
);

CREATE TABLE Lectures (
    Id INT PRIMARY KEY IDENTITY,
    TeacherId INT,
    Classroom NVARCHAR(10),
    DayOfWeek NVARCHAR(20),
    DepartmentId INT,
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id),
    FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
);

CREATE TABLE LectureStudents (
    LectureId INT,
    StudentId INT,
    FOREIGN KEY (LectureId) REFERENCES Lectures(Id),
    FOREIGN KEY (StudentId) REFERENCES Students(Id)
);

-- DATA
INSERT INTO Faculties (Name) VALUES ('Computer Science');

INSERT INTO Departments (Name, Financing, FacultyId)
VALUES ('Software Development', 100000, 1);

INSERT INTO Teachers (Name, Salary, DepartmentId, FacultyId)
VALUES 
('Dave McQueen', 5000, 1, 1),
('Jack Underhill', 6000, 1, 1);

INSERT INTO Students (Name)
VALUES ('John'), ('Anna'), ('Mike');

INSERT INTO Disciplines (Name, DepartmentId)
VALUES ('C++', 1), ('Databases', 1);

INSERT INTO TeacherDisciplines VALUES (1,1), (1,2), (2,1);

INSERT INTO Lectures (TeacherId, Classroom, DayOfWeek, DepartmentId)
VALUES 
(1, 'D201', 'Monday', 1),
(1, 'D201', 'Tuesday', 1),
(2, 'D202', 'Monday', 1);

INSERT INTO LectureStudents VALUES (1,1),(1,2),(2,3),(3,1);



-- 1
SELECT COUNT(*) FROM Teachers t
JOIN Departments d ON t.DepartmentId = d.Id
WHERE d.Name = 'Software Development';

-- 2
SELECT COUNT(*) FROM Lectures l
JOIN Teachers t ON l.TeacherId = t.Id
WHERE t.Name = 'Dave McQueen';

-- 3
SELECT COUNT(*) FROM Lectures
WHERE Classroom = 'D201';

-- 4
SELECT Classroom, COUNT(*) FROM Lectures
GROUP BY Classroom;

-- 5
SELECT COUNT(DISTINCT s.Id)
FROM Students s
JOIN LectureStudents ls ON s.Id = ls.StudentId
JOIN Lectures l ON ls.LectureId = l.Id
JOIN Teachers t ON l.TeacherId = t.Id
WHERE t.Name = 'Jack Underhill';

-- 6
SELECT AVG(Salary) FROM Teachers;

-- 7
SELECT AVG(Financing) FROM Departments;

-- 8
SELECT t.Name, COUNT(td.DisciplineId)
FROM Teachers t
JOIN TeacherDisciplines td ON t.Id = td.TeacherId
GROUP BY t.Name;

-- 9
SELECT DayOfWeek, COUNT(*) FROM Lectures
GROUP BY DayOfWeek;

-- 10
SELECT Classroom, COUNT(DISTINCT DepartmentId)
FROM Lectures
GROUP BY Classroom;

-- 11
SELECT f.Name, COUNT(d.Id)
FROM Faculties f
JOIN Departments dep ON dep.FacultyId = f.Id
JOIN Disciplines d ON d.DepartmentId = dep.Id
GROUP BY f.Name;

-- 12
SELECT TeacherId, Classroom, COUNT(*)
FROM Lectures
GROUP BY TeacherId, Classroom;
