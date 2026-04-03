CREATE DATABASE AcademyAdvanced;
GO

USE AcademyAdvanced;
GO


CREATE TABLE Teachers (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(MAX) NOT NULL,
    Surname NVARCHAR(MAX) NOT NULL
);
GO


CREATE TABLE Assistants (
    Id INT IDENTITY PRIMARY KEY,
    TeacherId INT NOT NULL,
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);
GO

CREATE TABLE Curators (
    Id INT IDENTITY PRIMARY KEY,
    TeacherId INT NOT NULL,
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);
GO


CREATE TABLE Deans (
    Id INT IDENTITY PRIMARY KEY,
    TeacherId INT NOT NULL,
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);
GO


CREATE TABLE Heads (
    Id INT IDENTITY PRIMARY KEY,
    TeacherId INT NOT NULL,
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);
GO


CREATE TABLE Faculties (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE,
    Building INT NOT NULL,
    DeanId INT NOT NULL,
    FOREIGN KEY (DeanId) REFERENCES Deans(Id)
);
GO


CREATE TABLE Departments (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE,
    Building INT NOT NULL,
    FacultyId INT NOT NULL,
    HeadId INT NOT NULL,
    FOREIGN KEY (FacultyId) REFERENCES Faculties(Id),
    FOREIGN KEY (HeadId) REFERENCES Heads(Id)
);
GO


CREATE TABLE Groups (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(10) NOT NULL UNIQUE,
    Year INT NOT NULL,
    DepartmentId INT NOT NULL,
    FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
);
GO


CREATE TABLE LectureRooms (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(10) NOT NULL UNIQUE,
    Building INT NOT NULL
);
GO


CREATE TABLE Subjects (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE
);
GO


CREATE TABLE Lectures (
    Id INT IDENTITY PRIMARY KEY,
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


CREATE TABLE Schedules (
    Id INT IDENTITY PRIMARY KEY,
    Class INT NOT NULL,
    DayOfWeek INT NOT NULL,
    Week INT NOT NULL,
    LectureId INT NOT NULL,
    LectureRoomId INT NOT NULL,
    FOREIGN KEY (LectureId) REFERENCES Lectures(Id),
    FOREIGN KEY (LectureRoomId) REFERENCES LectureRooms(Id)
);
GO



-- 1
SELECT lr.Name
FROM Teachers t
JOIN Lectures l ON t.Id = l.TeacherId
JOIN Schedules s ON s.LectureId = l.Id
JOIN LectureRooms lr ON lr.Id = s.LectureRoomId
WHERE t.Name = 'Edward' AND t.Surname = 'Hopper';

-- 2
SELECT t.Surname
FROM Teachers t
JOIN Assistants a ON a.TeacherId = t.Id
JOIN Lectures l ON l.TeacherId = t.Id
JOIN GroupsLectures gl ON gl.LectureId = l.Id
JOIN Groups g ON g.Id = gl.GroupId
WHERE g.Name = 'F505';

-- 3
SELECT DISTINCT sub.Name
FROM Teachers t
JOIN Lectures l ON l.TeacherId = t.Id
JOIN Subjects sub ON sub.Id = l.SubjectId
JOIN GroupsLectures gl ON gl.LectureId = l.Id
JOIN Groups g ON g.Id = gl.GroupId
WHERE t.Name = 'Alex' AND t.Surname = 'Carmack' AND g.Year = 5;

-- 4
SELECT Surname
FROM Teachers
WHERE Id NOT IN (
    SELECT TeacherId FROM Lectures l
    JOIN Schedules s ON s.LectureId = l.Id
    WHERE s.DayOfWeek = 1
);

-- 5
SELECT lr.Name, lr.Building
FROM LectureRooms lr
WHERE lr.Id NOT IN (
    SELECT s.LectureRoomId
    FROM Schedules s
    WHERE s.DayOfWeek = 3 AND s.Week = 2 AND s.Class = 3
);

-- 6
SELECT t.Name + ' ' + t.Surname
FROM Teachers t
JOIN Lectures l ON l.TeacherId = t.Id
JOIN GroupsLectures gl ON gl.LectureId = l.Id
JOIN Groups g ON g.Id = gl.GroupId
JOIN Departments d ON d.Id = g.DepartmentId
JOIN Faculties f ON f.Id = d.FacultyId
WHERE f.Name = 'Computer Science'
AND t.Id NOT IN (
    SELECT c.TeacherId
    FROM Curators c
    JOIN GroupsCurators gc ON gc.CuratorId = c.Id
    JOIN Groups g2 ON g2.Id = gc.GroupId
    JOIN Departments d2 ON d2.Id = g2.DepartmentId
    WHERE d2.Name = 'Software Development'
);

-- 7
SELECT Building FROM Faculties
UNION
SELECT Building FROM Departments
UNION
SELECT Building FROM LectureRooms;

-- 8
SELECT t.Name + ' ' + t.Surname, 1 AS RoleOrder FROM Teachers t JOIN Deans d ON d.TeacherId = t.Id
UNION ALL
SELECT t.Name + ' ' + t.Surname, 2 FROM Teachers t JOIN Heads h ON h.TeacherId = t.Id
UNION ALL
SELECT t.Name + ' ' + t.Surname, 3 FROM Teachers t
UNION ALL
SELECT t.Name + ' ' + t.Surname, 4 FROM Teachers t JOIN Curators c ON c.TeacherId = t.Id
UNION ALL
SELECT t.Name + ' ' + t.Surname, 5 FROM Teachers t JOIN Assistants a ON a.TeacherId = t.Id
ORDER BY RoleOrder;

-- 9
SELECT DISTINCT s.DayOfWeek
FROM Schedules s
JOIN LectureRooms lr ON lr.Id = s.LectureRoomId
WHERE lr.Name IN ('A311','A104') AND lr.Building = 6;
