using AcademyApp.Data;
using AcademyApp.Models;
using Microsoft.EntityFrameworkCore;

using var db = new AcademyContext();
db.Database.EnsureCreated();

while (true)
{
    Console.WriteLine();
    Console.WriteLine("=== Academy ===");
    Console.WriteLine("1  - Додати кафедру");
    Console.WriteLine("2  - Додати предмет");
    Console.WriteLine("3  - Додати викладача");
    Console.WriteLine("4  - Додати групу");
    Console.WriteLine("5  - Додати паспорт");
    Console.WriteLine("6  - Додати студента");
    Console.WriteLine("7  - Показати кафедри");
    Console.WriteLine("8  - Показати предмети");
    Console.WriteLine("9  - Показати викладачів");
    Console.WriteLine("10 - Показати групи");
    Console.WriteLine("11 - Показати студентів");
    Console.WriteLine("0  - Вихід");
    Console.Write("Вибір: ");

    var choice = Console.ReadLine();

    try
    {
        switch (choice)
        {
            case "1": AddDepartment(); break;
            case "2": AddSubject(); break;
            case "3": AddTeacher(); break;
            case "4": AddGroup(); break;
            case "5": AddPassport(); break;
            case "6": AddStudent(); break;
            case "7": ShowDepartments(); break;
            case "8": ShowSubjects(); break;
            case "9": ShowTeachers(); break;
            case "10": ShowGroups(); break;
            case "11": ShowStudents(); break;
            case "0": return;
            default:
                Console.WriteLine("Немає такого пункту");
                break;
        }
    }
    catch (Exception ex)
    {
        // якщо порушено якесь з обмежень Fluent API - побачимо помилку тут
        Console.WriteLine("Помилка: " + ex.Message);
    }
}

// ---------------- Create ----------------

void AddDepartment()
{
    Console.Write("Назва кафедри: ");
    var name = Console.ReadLine() ?? "";

    var dep = new Department { Name = name };
    db.Departments.Add(dep);
    db.SaveChanges();

    Console.WriteLine("Кафедру додано, Id = " + dep.Id);
}

void AddSubject()
{
    ShowDepartments();
    Console.Write("Id кафедри: ");
    var depId = int.Parse(Console.ReadLine()!);

    Console.Write("Назва предмету: ");
    var name = Console.ReadLine() ?? "";

    Console.Write("Опис (можна залишити пустим): ");
    var desc = Console.ReadLine();

    var subject = new Subject
    {
        Name = name,
        Description = string.IsNullOrWhiteSpace(desc) ? null : desc,
        DepartmentId = depId
    };

    db.Subjects.Add(subject);
    db.SaveChanges();

    Console.WriteLine("Предмет додано, Id = " + subject.Id);
}

void AddTeacher()
{
    Console.Write("Ім'я викладача: ");
    var name = Console.ReadLine() ?? "";

    Console.Write("Зарплата (Enter - буде 25000 за замовчуванням): ");
    var salaryStr = Console.ReadLine();

    var teacher = new Teacher { Name = name };

    if (!string.IsNullOrWhiteSpace(salaryStr))
        teacher.Salary = decimal.Parse(salaryStr);

    ShowSubjects();
    Console.Write("Id предметів через кому (можна залишити пустим): ");
    var subjIdsStr = Console.ReadLine();

    if (!string.IsNullOrWhiteSpace(subjIdsStr))
    {
        var ids = subjIdsStr.Split(',').Select(x => int.Parse(x.Trim())).ToList();
        teacher.Subjects = db.Subjects.Where(s => ids.Contains(s.Id)).ToList();
    }

    db.Teachers.Add(teacher);
    db.SaveChanges();

    Console.WriteLine("Викладача додано, Id = " + teacher.Id);
}

void AddGroup()
{
    Console.Write("Назва групи (до 10 символів): ");
    var name = Console.ReadLine() ?? "";

    var group = new Group { Name = name };
    db.Groups.Add(group);
    db.SaveChanges();

    Console.WriteLine("Групу додано, Id = " + group.Id);
}

void AddPassport()
{
    var studentsNoPassport = db.Students.Where(s => s.Passport == null).ToList();

    if (studentsNoPassport.Count == 0)
    {
        Console.WriteLine("Немає студентів без паспорта (спочатку додайте студента)");
        return;
    }

    Console.WriteLine("Студенти без паспорта:");
    foreach (var s in studentsNoPassport)
        Console.WriteLine(s.Id + " - " + s.Name);

    Console.Write("Id студента: ");
    var studentId = int.Parse(Console.ReadLine()!);

    Console.Write("Номер паспорту (9 цифр): ");
    var number = Console.ReadLine() ?? "";

    var passport = new Passport { Number = number, StudentId = studentId };
    db.Passports.Add(passport);
    db.SaveChanges();

    Console.WriteLine("Паспорт додано, Id = " + passport.Id);
}

void AddStudent()
{
    ShowGroups();
    Console.Write("Id групи: ");
    var groupId = int.Parse(Console.ReadLine()!);

    Console.Write("Ім'я студента: ");
    var name = Console.ReadLine() ?? "";

    Console.Write("Email: ");
    var email = Console.ReadLine() ?? "";

    Console.Write("Тип стипендії (наприклад 1500.00): ");
    var scholarship = decimal.Parse(Console.ReadLine()!);

    var student = new Student
    {
        Name = name,
        Email = email,
        ScholarshipType = scholarship,
        GroupId = groupId
    };

    db.Students.Add(student);
    db.SaveChanges();

    Console.WriteLine("Студента додано, Id = " + student.Id);
}

// ---------------- Read ----------------

void ShowDepartments()
{
    var deps = db.Departments.Include(d => d.Subjects).ToList();

    Console.WriteLine("--- Кафедри ---");
    foreach (var d in deps)
        Console.WriteLine(d.Id + " | " + d.Name + " | предметів: " + d.Subjects.Count);
}

void ShowSubjects()
{
    var subjects = db.Subjects
        .Include(s => s.Department)
        .Include(s => s.Teachers)
        .ToList();

    Console.WriteLine("--- Предмети ---");
    foreach (var s in subjects)
        Console.WriteLine(s.Id + " | " + s.Name +
            " | кафедра: " + (s.Department?.Name ?? "-") +
            " | викладачів: " + s.Teachers.Count);
}

void ShowTeachers()
{
    var teachers = db.Teachers.Include(t => t.Subjects).ToList();

    Console.WriteLine("--- Викладачі ---");
    foreach (var t in teachers)
        Console.WriteLine(t.Id + " | " + t.Name +
            " | зарплата: " + t.Salary +
            " | предметів: " + t.Subjects.Count);
}

void ShowGroups()
{
    var groups = db.Groups.Include(g => g.Students).ToList();

    Console.WriteLine("--- Групи ---");
    foreach (var g in groups)
        Console.WriteLine(g.Id + " | " + g.Name + " | студентів: " + g.Students.Count);
}

void ShowStudents()
{
    var students = db.Students
        .Include(s => s.Group)
        .Include(s => s.Passport)
        .ToList();

    Console.WriteLine("--- Студенти ---");
    foreach (var s in students)
        Console.WriteLine(s.Id + " | " + s.Name + " | " + s.Email +
            " | стипендія: " + s.ScholarshipType +
            " | група: " + (s.Group?.Name ?? "-") +
            " | паспорт: " + (s.Passport?.Number ?? "-"));
}
