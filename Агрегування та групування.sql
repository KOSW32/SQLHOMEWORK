CREATE DATABASE Academy;
GO

USE Academy;
GO


CREATE TABLE Faculties (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE
);
GO


CREATE TABLE Departments (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE,
    Financing MONEY NOT NULL DEFAULT 0 CHECK (Financing >= 0),
    FacultyId INT NOT NULL,
    FOREIGN KEY (FacultyId) REFERENCES Faculties(Id)
);
GO


CREATE TABLE Groups (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(10) NOT NULL UNIQUE,
    Year INT NOT NULL CHECK (Year BETWEEN 1 AND 5),
    DepartmentId INT NOT NULL,
    FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
);
GO


CREATE TABLE Teachers (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(MAX) NOT NULL,
    Surname NVARCHAR(MAX) NOT NULL,
    Salary MONEY NOT NULL CHECK (Salary > 0)
);
GO


CREATE TABLE Subjects (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE
);
GO


CREATE TABLE Lectures (
    Id INT IDENTITY PRIMARY KEY,
    DayOfWeek INT NOT NULL CHECK (DayOfWeek BETWEEN 1 AND 7),
    LectureRoom NVARCHAR(MAX) NOT NULL,
    SubjectId INT NOT NULL,
    TeacherId INT NOT NULL,
    FOREIGN KEY (SubjectId) REFERENCES Subjects(Id),
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);
GO


CREATE TABLE GroupsLectures (
    Id INT IDENTITY PRIMARY KEY,
    GroupId INT NOT NULL,
    LectureId INT NOT NULL,
    FOREIGN KEY (GroupId) REFERENCES Groups(Id),
    FOREIGN KEY (LectureId) REFERENCES Lectures(Id)
);
GO


-- 1
SELECT COUNT(*) 
FROM Teachers t
JOIN Lectures l ON t.Id = l.TeacherId
JOIN GroupsLectures gl ON l.Id = gl.LectureId
JOIN Groups g ON g.Id = gl.GroupId
JOIN Departments d ON d.Id = g.DepartmentId
WHERE d.Name = 'Software Development';
GO

-- 2
SELECT COUNT(*)
FROM Lectures l
JOIN Teachers t ON t.Id = l.TeacherId
WHERE t.Name = 'Dave' AND t.Surname = 'McQueen';
GO

-- 3
SELECT COUNT(*)
FROM Lectures
WHERE LectureRoom = 'D201';
GO

-- 4
SELECT LectureRoom, COUNT(*) AS LectureCount
FROM Lectures
GROUP BY LectureRoom;
GO

-- 5
SELECT COUNT(DISTINCT gl.GroupId)
FROM Lectures l
JOIN Teachers t ON t.Id = l.TeacherId
JOIN GroupsLectures gl ON gl.LectureId = l.Id
WHERE t.Name = 'Jack' AND t.Surname = 'Underhill';
GO

-- 6
SELECT AVG(t.Salary)
FROM Teachers t
JOIN Lectures l ON t.Id = l.TeacherId
JOIN GroupsLectures gl ON gl.LectureId = l.Id
JOIN Groups g ON g.Id = gl.GroupId
JOIN Departments d ON d.Id = g.DepartmentId
JOIN Faculties f ON f.Id = d.FacultyId
WHERE f.Name = 'Computer Science';
GO

-- 7
SELECT AVG(Financing)
FROM Departments;
GO

-- 8
SELECT t.Name + ' ' + t.Surname AS FullName, COUNT(DISTINCT s.Id) AS SubjectsCount
FROM Teachers t
JOIN Lectures l ON t.Id = l.TeacherId
JOIN Subjects s ON s.Id = l.SubjectId
GROUP BY t.Name, t.Surname;
GO

-- 9
SELECT DayOfWeek, COUNT(*) AS LecturesCount
FROM Lectures
GROUP BY DayOfWeek;
GO

-- 10
SELECT l.LectureRoom, COUNT(DISTINCT d.Id) AS DepartmentsCount
FROM Lectures l
JOIN GroupsLectures gl ON gl.LectureId = l.Id
JOIN Groups g ON g.Id = gl.GroupId
JOIN Departments d ON d.Id = g.DepartmentId
GROUP BY l.LectureRoom;
GO

-- 11
SELECT f.Name, COUNT(DISTINCT s.Id) AS SubjectsCount
FROM Faculties f
JOIN Departments d ON d.FacultyId = f.Id
JOIN Groups g ON g.DepartmentId = d.Id
JOIN GroupsLectures gl ON gl.GroupId = g.Id
JOIN Lectures l ON l.Id = gl.LectureId
JOIN Subjects s ON s.Id = l.SubjectId
GROUP BY f.Name;
GO

-- 12
SELECT t.Name + ' ' + t.Surname AS Teacher,
       l.LectureRoom,
       COUNT(*) AS LecturesCount
FROM Lectures l
JOIN Teachers t ON t.Id = l.TeacherId
GROUP BY t.Name, t.Surname, l.LectureRoom;
GO
