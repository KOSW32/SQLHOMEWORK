# AcademyApp

Консольний застосунок EF Core Fluent API (Group, Student, Passport, Teacher, Subject, Department).

## Як запустити

1. Відкрити папку в Visual Studio / Rider або через `dotnet`.
2. У файлі `Data/AcademyContext.cs` перевірити рядок підключення в `OnConfiguring`
   (за замовчуванням LocalDB, назва бази `AcademyDb`).
3. Створити міграцію і базу:

```
dotnet ef migrations add Init
dotnet ef database update
```

(якщо немає `dotnet-ef`: `dotnet tool install --global dotnet-ef`)

4. Запустити:

```
dotnet run
```

Далі працює текстове меню: пункти 1-6 - додавання (Create), пункти 7-11 - перегляд (Read)
зі зв'язаними даними через `Include`.

## Що зроблено по Fluent API

- Group: `Name` макс. 10 символів, `IsRequired`, check-constraint на непустий рядок.
- Student: `Name` до 50 символів, унікальний `Email` (+ check на формат пошти),
  `ScholarshipType` -> `decimal(6,2)`, FK на Group, one-to-one на Passport.
- Passport: `Number` фіксовано 9 символів, check на "рівно 9 цифр".
- Teacher: `Salary` -> `decimal(8,2)`, `HasDefaultValue(25000)`, check `Salary > 0`,
  `Name` до 50 символів + check на непустий рядок, many-to-many з Subject.
- Subject: `Name` до 50 символів + check, `Description` nullable, FK на Department,
  many-to-many з Teacher.
- Department: `Name` до 50 символів + check, один-до-багатьох з Subject.
