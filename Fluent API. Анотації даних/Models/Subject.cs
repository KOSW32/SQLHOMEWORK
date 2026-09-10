namespace AcademyApp.Models;

public class Subject
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }

    // звязок з кафедрою
    public int DepartmentId { get; set; }
    public Department? Department { get; set; }

    // звязок з викладачами (багато до багатьох)
    public List<Teacher> Teachers { get; set; } = new();
}
