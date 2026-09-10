using MovieApp.Models;
using Microsoft.EntityFrameworkCore;

namespace MovieApp.Data;

public class MovieContext : DbContext
{
    public DbSet<User> Users => Set<User>();
    public DbSet<Movie> Movies => Set<Movie>();

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        // рядок підключення - під свою локальну базу (LocalDB / SQL Server)
        optionsBuilder.UseSqlServer(
            @"Server=(localdb)\MSSQLLocalDB;Database=MovieDb;Trusted_Connection=True;TrustServerCertificate=True;");
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // ---------------- Користувач ----------------
        modelBuilder.Entity<User>(e =>
        {
            e.Property(u => u.Username)
                .IsRequired();

            e.HasIndex(u => u.Username)
                .IsUnique();

            e.Property(u => u.Email)
                .IsRequired();

            e.HasIndex(u => u.Email)
                .IsUnique();

            e.Property(u => u.Password)
                .IsRequired();

            e.ToTable(t =>
            {
                // username не пустий рядок
                t.HasCheckConstraint("CK_User_Username_NotEmpty", "LEN(Username) > 0");
                // email за шаблоном щось@щось.щось
                t.HasCheckConstraint("CK_User_Email_Format", "Email LIKE '%_@__%.__%'");
            });
        });

        // ---------------- Фільм ----------------
        modelBuilder.Entity<Movie>(e =>
        {
            e.Property(m => m.Title)
                .IsRequired()
                .HasMaxLength(50);

            e.Property(m => m.Description)
                .IsRequired(false);

            e.Property(m => m.AddedDate)
                .HasDefaultValueSql("GETDATE()");

            e.ToTable(t =>
            {
                t.HasCheckConstraint("CK_Movie_Title_NotEmpty", "LEN(Title) > 0");
                t.HasCheckConstraint("CK_Movie_ReleaseYear_Positive", "ReleaseYear > 0");
            });

            // звязок з користувачем, який додав фільм
            e.HasOne(m => m.User)
                .WithMany(u => u.Movies)
                .HasForeignKey(m => m.UserId)
                .OnDelete(DeleteBehavior.Restrict);
        });
    }
}
