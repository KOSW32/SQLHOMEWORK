using AcademyApp.Models;
using Microsoft.EntityFrameworkCore;

namespace AcademyApp.Data;

public class AcademyContext : DbContext
{
    public DbSet<Group> Groups => Set<Group>();
    public DbSet<Student> Students => Set<Student>();
    public DbSet<Passport> Passports => Set<Passport>();
    public DbSet<Teacher> Teachers => Set<Teacher>();
    public DbSet<Subject> Subjects => Set<Subject>();
    public DbSet<Department> Departments => Set<Department>();

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        // рядок підключення - під свою локальну базу (LocalDB / SQL Server)
        optionsBuilder.UseSqlServer(
            @"Server=(localdb)\MSSQLLocalDB;Database=AcademyDb;Trusted_Connection=True;TrustServerCertificate=True;");
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // ---------------- Група ----------------
        modelBuilder.Entity<Group>(e =>
        {
            e.Property(g => g.Name)
                .IsRequired()
                .HasMaxLength(10);

            e.ToTable(t => t.HasCheckConstraint("CK_Group_Name_NotEmpty", "LEN(Name) > 0"));
        });

        // ---------------- Студент ----------------
        modelBuilder.Entity<Student>(e =>
        {
            e.Property(s => s.Name)
                .IsRequired()
                .HasMaxLength(50);

            e.Property(s => s.Email)
                .IsRequired();

            e.HasIndex(s => s.Email)
                .IsUnique();

            e.Property(s => s.ScholarshipType)
                .HasColumnType("decimal(6,2)");

            // перевірка формату пошти на рівні БД (щось@щось.щось)
            e.ToTable(t => t.HasCheckConstraint("CK_Student_Email_Format",
                "Email LIKE '%_@__%.__%'"));

            // звязок з групою
            e.HasOne(s => s.Group)
                .WithMany(g => g.Students)
                .HasForeignKey(s => s.GroupId)
                .OnDelete(DeleteBehavior.Restrict);

            // звязок з паспортом (один до одного)
            e.HasOne(s => s.Passport)
                .WithOne(p => p.Student)
                .HasForeignKey<Passport>(p => p.StudentId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // ---------------- Паспорт ----------------
        modelBuilder.Entity<Passport>(e =>
        {
            e.Property(p => p.Number)
                .IsRequired()
                .HasMaxLength(9)
                .IsFixedLength();

            // рівно 9 цифр
            e.ToTable(t => t.HasCheckConstraint("CK_Passport_Number_Digits",
                "LEN(Number) = 9 AND Number NOT LIKE '%[^0-9]%'"));
        });

        // ---------------- Викладач ----------------
        modelBuilder.Entity<Teacher>(e =>
        {
            e.Property(t => t.Name)
                .IsRequired()
                .HasMaxLength(50);

            e.Property(t => t.Salary)
                .HasColumnType("decimal(8,2)")
                .HasDefaultValue(25000m);

            e.ToTable(t =>
            {
                t.HasCheckConstraint("CK_Teacher_Name_NotEmpty", "LEN(Name) > 0");
                t.HasCheckConstraint("CK_Teacher_Salary_Positive", "Salary > 0");
            });

            // звязок з предметами (багато до багатьох)
            e.HasMany(t => t.Subjects)
                .WithMany(s => s.Teachers)
                .UsingEntity(j => j.ToTable("TeacherSubject"));
        });

        // ---------------- Предмет ----------------
        modelBuilder.Entity<Subject>(e =>
        {
            e.Property(s => s.Name)
                .IsRequired()
                .HasMaxLength(50);

            e.Property(s => s.Description)
                .IsRequired(false);

            e.ToTable(t => t.HasCheckConstraint("CK_Subject_Name_NotEmpty", "LEN(Name) > 0"));

            // звязок з кафедрою
            e.HasOne(s => s.Department)
                .WithMany(d => d.Subjects)
                .HasForeignKey(s => s.DepartmentId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        // ---------------- Кафедра ----------------
        modelBuilder.Entity<Department>(e =>
        {
            e.Property(d => d.Name)
                .IsRequired()
                .HasMaxLength(50);

            e.ToTable(t => t.HasCheckConstraint("CK_Department_Name_NotEmpty", "LEN(Name) > 0"));
        });
    }
}
