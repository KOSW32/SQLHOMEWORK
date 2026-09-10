namespace AcademyApp.Models;

public class Teacher
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal Salary { get; set; }

    public List<Subject> Subjects { get; set; } = new();
}
