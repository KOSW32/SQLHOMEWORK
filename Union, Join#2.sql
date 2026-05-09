USE master;

CREATE TABLE Teachers (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(MAX) NOT NULL,
    Surname NVARCHAR(MAX) NOT NULL
);

CREATE TABLE Assistants (
    Id INT IDENTITY PRIMARY KEY,
    TeacherId INT NOT NULL REFERENCES Teachers(Id)
);

CREATE TABLE Curators (
    Id INT IDENTITY PRIMARY KEY,
    TeacherId INT NOT NULL REFERENCES Teachers(Id)
);

CREATE TABLE Deans (
    Id INT IDENTITY PRIMARY KEY,
    TeacherId INT NOT NULL REFERENCES Teachers(Id)
);

CREATE TABLE Heads (
    Id INT IDENTITY PRIMARY KEY,
    TeacherId INT NOT NULL REFERENCES Teachers(Id)
);

CREATE TABLE Faculties (
    Id INT IDENTITY PRIMARY KEY,
    Building INT NOT NULL,
    Name NVARCHAR(100) NOT NULL UNIQUE,
    DeanId INT NOT NULL REFERENCES Deans(Id)
);

CREATE TABLE Departments (
    Id INT IDENTITY PRIMARY KEY,
    Building INT NOT NULL,
    Name NVARCHAR(100) NOT NULL UNIQUE,
    FacultyId INT NOT NULL REFERENCES Faculties(Id),
    HeadId INT NOT NULL REFERENCES Heads(Id)
);

CREATE TABLE Groups (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(10) NOT NULL UNIQUE,
    Year INT NOT NULL,
    DepartmentId INT NOT NULL REFERENCES Departments(Id)
);

CREATE TABLE GroupsCurators (
    Id INT IDENTITY PRIMARY KEY,
    CuratorId INT NOT NULL REFERENCES Curators(Id),
    GroupId INT NOT NULL REFERENCES Groups(Id)
);

CREATE TABLE Subjects (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Lectures (
    Id INT IDENTITY PRIMARY KEY,
    SubjectId INT NOT NULL REFERENCES Subjects(Id),
    TeacherId INT NOT NULL REFERENCES Teachers(Id)
);

CREATE TABLE GroupsLectures (
    Id INT IDENTITY PRIMARY KEY,
    GroupId INT NOT NULL REFERENCES Groups(Id),
    LectureId INT NOT NULL REFERENCES Lectures(Id)
);

CREATE TABLE LectureRooms (
    Id INT IDENTITY PRIMARY KEY,
    Building INT NOT NULL,
    Name NVARCHAR(10) NOT NULL UNIQUE
);

CREATE TABLE Schedules (
    Id INT IDENTITY PRIMARY KEY,
    Class INT NOT NULL,
    DayOfWeek INT NOT NULL,
    Week INT NOT NULL,
    LectureId INT NOT NULL REFERENCES Lectures(Id),
    LectureRoomId INT NOT NULL REFERENCES LectureRooms(Id)
);

INSERT INTO Teachers(Name,Surname) VALUES
('Edward','Hopper'),
('Alex','Carmack'),
('John','Smith'),
('Anna','Brown'),
('Mike','Wilson');

INSERT INTO Assistants(TeacherId) VALUES
(3),
(4);

INSERT INTO Curators(TeacherId) VALUES
(4);

INSERT INTO Deans(TeacherId) VALUES
(1);

INSERT INTO Heads(TeacherId) VALUES
(2);

INSERT INTO Faculties(Building,Name,DeanId) VALUES
(1,'Computer Science',1);

INSERT INTO Departments(Building,Name,FacultyId,HeadId) VALUES
(2,'Software Development',1,1),
(3,'Cyber Security',1,1);

INSERT INTO Groups(Name,Year,DepartmentId) VALUES
('F505',5,1),
('A101',1,2);

INSERT INTO GroupsCurators(CuratorId,GroupId) VALUES
(1,1);

INSERT INTO Subjects(Name) VALUES
('Databases'),
('C++'),
('Networks');

INSERT INTO Lectures(SubjectId,TeacherId) VALUES
(1,1),
(2,2),
(3,3);

INSERT INTO GroupsLectures(GroupId,LectureId) VALUES
(1,1),
(1,2),
(2,3);

INSERT INTO LectureRooms(Building,Name) VALUES
(6,'A311'),
(6,'A104'),
(2,'B201');

INSERT INTO Schedules(Class,DayOfWeek,Week,LectureId,LectureRoomId) VALUES
(1,1,1,1,1),
(3,3,2,2,2),
(2,5,1,3,3);

SELECT DISTINCT lr.Name
FROM LectureRooms lr
JOIN Schedules s ON s.LectureRoomId = lr.Id
JOIN Lectures l ON l.Id = s.LectureId
JOIN Teachers t ON t.Id = l.TeacherId
WHERE t.Name = 'Edward' AND t.Surname = 'Hopper';

SELECT DISTINCT t.Surname
FROM Teachers t
JOIN Assistants a ON a.TeacherId = t.Id
JOIN Lectures l ON l.TeacherId = t.Id
JOIN GroupsLectures gl ON gl.LectureId = l.Id
JOIN Groups g ON g.Id = gl.GroupId
WHERE g.Name = 'F505';

SELECT DISTINCT s.Name
FROM Subjects s
JOIN Lectures l ON l.SubjectId = s.Id
JOIN Teachers t ON t.Id = l.TeacherId
JOIN GroupsLectures gl ON gl.LectureId = l.Id
JOIN Groups g ON g.Id = gl.GroupId
WHERE t.Name = 'Alex'
AND t.Surname = 'Carmack'
AND g.Year = 5;

SELECT Surname
FROM Teachers
WHERE Id NOT IN (
    SELECT l.TeacherId
    FROM Lectures l
    JOIN Schedules s ON s.LectureId = l.Id
    WHERE s.DayOfWeek = 1
);

SELECT lr.Name, lr.Building
FROM LectureRooms lr
WHERE lr.Id NOT IN (
    SELECT LectureRoomId
    FROM Schedules
    WHERE DayOfWeek = 3
    AND Week = 2
    AND Class = 3
);

SELECT t.Name + ' ' + t.Surname
FROM Teachers t
WHERE t.Id NOT IN (
    SELECT c.TeacherId
    FROM Curators c
    JOIN GroupsCurators gc ON gc.CuratorId = c.Id
    JOIN Groups g ON g.Id = gc.GroupId
    JOIN Departments d ON d.Id = g.DepartmentId
    WHERE d.Name = 'Software Development'
);

SELECT Building FROM Faculties
UNION
SELECT Building FROM Departments
UNION
SELECT Building FROM LectureRooms;

SELECT t.Name + ' ' + t.Surname
FROM Teachers t
LEFT JOIN Deans d ON d.TeacherId = t.Id
LEFT JOIN Heads h ON h.TeacherId = t.Id
LEFT JOIN Curators c ON c.TeacherId = t.Id
LEFT JOIN Assistants a ON a.TeacherId = t.Id
ORDER BY
CASE
    WHEN d.TeacherId IS NOT NULL THEN 1
    WHEN h.TeacherId IS NOT NULL THEN 2
    WHEN c.TeacherId IS NOT NULL THEN 4
    WHEN a.TeacherId IS NOT NULL THEN 5
    ELSE 3
END;

SELECT DISTINCT s.DayOfWeek
FROM Schedules s
JOIN LectureRooms lr ON lr.Id = s.LectureRoomId
WHERE lr.Building = 6
AND lr.Name IN ('A311', 'A104');
