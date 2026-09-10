# MovieApp

Консольний застосунок EF Core Fluent API (User, Movie).

## Як запустити

1. Відкрити папку у Visual Studio / Rider або через `dotnet`.
2. У `Data/MovieContext.cs` перевірити рядок підключення в `OnConfiguring`
   (за замовчуванням LocalDB, база `MovieDb`).
3. Створити міграцію і базу:

```
dotnet ef migrations add Init
dotnet ef database update
```

4. Запустити:

```
dotnet run
```

## Що зроблено по Fluent API

- User: `Username` унікальний + check на непустий рядок, `Email` унікальний +
  check на формат (щось@щось.щось), `Password` обов'язковий.
- Movie: `Title` до 50 символів + check на непустий рядок, `ReleaseYear` -
  check `> 0`, `Description` nullable, `AddedDate` -> `HasDefaultValueSql("GETDATE()")`
  (тому в коді при створенні фільму це поле не заповнюється вручну - його
  підставляє сама БД), FK на `User` (хто додав фільм).
