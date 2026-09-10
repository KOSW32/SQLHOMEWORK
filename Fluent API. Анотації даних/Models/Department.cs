namespace AcademyApp.Models;

public class Department
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;

    public List<Subject> Subjects { get; set; } = new();
}
