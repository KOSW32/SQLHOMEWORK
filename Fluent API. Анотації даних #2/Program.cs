using MovieApp.Data;
using MovieApp.Models;
using Microsoft.EntityFrameworkCore;

using var db = new MovieContext();
db.Database.EnsureCreated();

while (true)
{
    Console.WriteLine();
    Console.WriteLine("=== MovieApp ===");
    Console.WriteLine("1 - Додати користувача");
    Console.WriteLine("2 - Додати фільм");
    Console.WriteLine("3 - Показати користувачів");
    Console.WriteLine("4 - Показати фільми");
    Console.WriteLine("0 - Вихід");
    Console.Write("Вибір: ");

    var choice = Console.ReadLine();

    try
    {
        switch (choice)
        {
            case "1": AddUser(); break;
            case "2": AddMovie(); break;
            case "3": ShowUsers(); break;
            case "4": ShowMovies(); break;
            case "0": return;
            default:
                Console.WriteLine("Немає такого пункту");
                break;
        }
    }
    catch (Exception ex)
    {
        // сюди попадуть помилки типу порушення унікальності username/email
        // або перевірок (check constraints) з Fluent API
        Console.WriteLine("Помилка: " + ex.Message);
    }
}

// ---------------- Create ----------------

void AddUser()
{
    Console.Write("Username: ");
    var username = Console.ReadLine() ?? "";

    Console.Write("Email: ");
    var email = Console.ReadLine() ?? "";

    Console.Write("Пароль: ");
    var password = Console.ReadLine() ?? "";

    var user = new User
    {
        Username = username,
        Email = email,
        Password = password
    };

    db.Users.Add(user);
    db.SaveChanges();

    Console.WriteLine("Користувача додано, Id = " + user.Id);
}

void AddMovie()
{
    ShowUsers();
    Console.Write("Id користувача, який додає фільм: ");
    var userId = int.Parse(Console.ReadLine()!);

    Console.Write("Назва фільму: ");
    var title = Console.ReadLine() ?? "";

    Console.Write("Рік виходу: ");
    var year = int.Parse(Console.ReadLine()!);

    Console.Write("Опис (можна залишити пустим): ");
    var desc = Console.ReadLine();

    var movie = new Movie
    {
        Title = title,
        ReleaseYear = year,
        Description = string.IsNullOrWhiteSpace(desc) ? null : desc,
        UserId = userId
        // AddedDate спеціально не чіпаємо - за замовчуванням підставить GETDATE() на рівні БД
    };

    db.Movies.Add(movie);
    db.SaveChanges();

    Console.WriteLine("Фільм додано, Id = " + movie.Id);
}

// ---------------- Read ----------------

void ShowUsers()
{
    var users = db.Users.Include(u => u.Movies).ToList();

    Console.WriteLine("--- Користувачі ---");
    foreach (var u in users)
        Console.WriteLine(u.Id + " | " + u.Username + " | " + u.Email +
            " | фільмів додано: " + u.Movies.Count);
}

void ShowMovies()
{
    var movies = db.Movies.Include(m => m.User).ToList();

    Console.WriteLine("--- Фільми ---");
    foreach (var m in movies)
        Console.WriteLine(m.Id + " | " + m.Title +
            " | " + m.ReleaseYear +
            " | додав: " + (m.User?.Username ?? "-") +
            " | дата додавання: " + m.AddedDate);
}
